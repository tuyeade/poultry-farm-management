import 'dart:convert';

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/report_overview.dart';
import '../../data/repositories/reports_repository.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ReportsRepository _repository = ReportsRepository();
  late Future<ReportOverview> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = _repository.getOverview();

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final report = await _future;
      final rows = <List<String>>[
        ['Report', 'Title', 'Details', 'Value', 'Date'],
      ];
      for (final section in report.details.entries) {
        for (final entry in section.value) {
          rows.add([
            section.key,
            entry.title,
            entry.subtitle,
            entry.value,
            DateFormat('yyyy-MM-dd').format(entry.date),
          ]);
        }
      }
      final csv = rows.map((row) => row.map(_csvCell).join(',')).join('\n');
      await Share.shareXFiles(
        [
          XFile.fromData(
            utf8.encode(csv),
            name: 'poultry-farm-report.csv',
            mimeType: 'text/csv',
          ),
        ],
        subject: l10n.reports,
        text: l10n.reports,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  String _csvCell(String value) =>
      '"${value.replaceAll('"', '""')}"';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.reports,
          style: AppTextStyles.heading3.copyWith(color: AppColors.textLight),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        actions: [
          IconButton(
            onPressed: _export,
            tooltip: l10n.export,
            icon: const Icon(Icons.download_outlined),
          ),
        ],
      ),
      body: FutureBuilder<ReportOverview>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: OutlinedButton.icon(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: _ReportBody(report: snapshot.data ?? ReportOverview.empty),
          );
        },
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  final ReportOverview report;
  const _ReportBody({required this.report});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChartCard(
            title: AppLocalizations.of(context)!.eggProduction,
            trailing: '${report.totalEggs} eggs total',
            child: _eggChart(),
          ),
          const SizedBox(height: 16),
          _ChartCard(title: AppLocalizations.of(context)!.incomeExpense, child: _incomeChart()),
          const SizedBox(height: 16),
          _ChartCard(
            title: AppLocalizations.of(context)!.revenueBreakdown,
            child: _revenueChart(context),
          ),
          const SizedBox(height: 16),
          _mortalityCard(context),
          const SizedBox(height: 16),
          _detail(
            context,
            AppLocalizations.of(context)!.financialReport,
            report.details['Financial Report'] ?? const [],
          ),
          _detail(
            context,
            AppLocalizations.of(context)!.productionReport,
            report.details['Production Report'] ?? const [],
          ),
        ],
      ),
    );
  }

  Widget _eggChart() {
    final values = report.monthly.map((item) => item.eggs.toDouble()).toList();
    final maximum = math.max(1.0, values.fold(0.0, math.max) * 1.2);
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maximum,
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: _titles(report.monthly.map((item) => item.label).toList()),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < values.length; i++)
                FlSpot(i.toDouble(), values[i]),
            ],
            isCurved: true,
            color: AppColors.secondary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _incomeChart() {
    final maximum = math.max(
      1.0,
      report.monthly.fold(
            0.0,
            (max, item) => math.max(max, math.max(item.income, item.expenses)),
          ) *
          1.2,
    );
    return BarChart(
      BarChartData(
        maxY: maximum,
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: _titles(report.monthly.map((item) => item.label).toList()),
        barGroups: [
          for (var i = 0; i < report.monthly.length; i++)
            BarChartGroupData(
              x: i,
              barsSpace: 3,
              barRods: [
                BarChartRodData(
                  toY: report.monthly[i].income,
                  color: AppColors.success,
                  width: 8,
                ),
                BarChartRodData(
                  toY: report.monthly[i].expenses,
                  color: AppColors.primaryLight,
                  width: 8,
                ),
              ],
            ),
        ],
      ),
    );
  }

  FlTitlesData _titles(List<String> labels) {
    return FlTitlesData(
      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 24,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= labels.length) {
              return const SizedBox.shrink();
            }
            return SideTitleWidget(
              meta: meta,
              child: Text(labels[index], style: AppTextStyles.bodySmall),
            );
          },
        ),
      ),
    );
  }

  Widget _revenueChart(BuildContext context) {
    final entries = report.revenueBreakdown.entries.toList();
    if (entries.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noRevenueData));
    }
    final colors = [
      AppColors.secondary,
      AppColors.primary,
      AppColors.accent,
      AppColors.primaryLight,
    ];
    final total = entries.fold(0.0, (sum, item) => sum + item.value);
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              centerSpaceRadius: 34,
              sectionsSpace: 2,
              sections: [
                for (var i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    value: entries[i].value,
                    color: colors[i % colors.length],
                    radius: 32,
                    showTitle: false,
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < entries.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        color: colors[i % colors.length],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entries[i].key,
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                      Text(
                        '${(entries[i].value / total * 100).round()}%',
                        style: AppTextStyles.titleMedium,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mortalityCard(BuildContext context) => Card(
    elevation: 0,
    color: AppColors.surface,
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.birdMortalityRate, style: AppTextStyles.titleLarge),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${report.mortalityRate.toStringAsFixed(1)}%',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.primary,
                  fontSize: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LinearProgressIndicator(
                  value: (report.mortalityRate / 100).clamp(0, 1).toDouble(),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _detail(
    BuildContext context,
    String title,
    List<ReportEntry> entries,
  ) => Card(
    elevation: 0,
    color: AppColors.surface,
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      title: Text(title, style: AppTextStyles.titleMedium),
      subtitle: Text(AppLocalizations.of(context)!.openDetailedRecords),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        builder: (_) => _DetailsSheet(title: title, entries: entries),
      ),
    ),
  );
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String? trailing;
  final Widget child;
  const _ChartCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: AppColors.surface,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppTextStyles.titleLarge)),
              if (trailing != null)
                Text(trailing!, style: AppTextStyles.bodySmall),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(height: 170, child: child),
        ],
      ),
    ),
  );
}

class _DetailsSheet extends StatelessWidget {
  final String title;
  final List<ReportEntry> entries;
  const _DetailsSheet({required this.title, required this.entries});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.7,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          Expanded(
            child: entries.isEmpty
                ? Center(child: Text(AppLocalizations.of(context)!.noRecordsFound))
                : ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (_, index) {
                      final entry = entries[index];
                      return ListTile(
                        title: Text(entry.title),
                        subtitle: Text(entry.subtitle),
                        trailing: Text(entry.value),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
  );
}
