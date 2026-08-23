import 'package:flutter/material.dart';
import 'package:poultry_farm_management/features/dashboard/presentation/widgets/dashbord_header.dart';
import 'package:poultry_farm_management/features/dashboard/presentation/widgets/quick_action_card.dart';
import 'package:poultry_farm_management/features/dashboard/presentation/widgets/statistic_card.dart';
import 'package:poultry_farm_management/features/dashboard/presentation/widgets/weekly_chart.dart';
import 'package:poultry_farm_management/features/dashboard/presentation/widgets/recent_activity_card.dart';
import 'package:poultry_farm_management/app/theme/app_colors.dart';
import 'package:poultry_farm_management/features/dashboard/data/models/dashboard_summary.dart';
import 'package:poultry_farm_management/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:poultry_farm_management/features/finance/presentation/pages/finance_page.dart';
import 'package:poultry_farm_management/features/feed/presentation/pages/feed_management_page.dart';
import 'package:poultry_farm_management/features/production/presentation/pages/daily_production_page.dart';
import 'package:poultry_farm_management/app/localization/generated/app_localizations.dart';

enum DashboardAction { production, sale, feed, expense }

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int totalChickens = 0;
  bool isLoadingChickens = true;
  final DashboardRepository _dashboardRepository = DashboardRepository();
  DashboardSummary _summary = DashboardSummary.empty;
  Object? _summaryError;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> loadTotalChickens() async {
    await _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() {
      isLoadingChickens = true;
      _summaryError = null;
    });

    try {
      final summary = await _dashboardRepository.getSummary();
      if (!mounted) return;
      setState(() {
        _summary = summary;
        totalChickens = summary.totalBirds;
        isLoadingChickens = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        isLoadingChickens = false;
        _summaryError = error;
      });
    }
  }

  Future<void> _openAction(DashboardAction action) async {
    final page = switch (action) {
      DashboardAction.production => const DailyProductionPage(),
      DashboardAction.sale => const FinancePage(),
      DashboardAction.feed => const FeedManagementPage(),
      DashboardAction.expense => const FinancePage(),
    };
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) await _loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chickensValue = isLoadingChickens ? '...' : totalChickens.toString();

    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardHeader(
                totalChickens: chickensValue,
                eggsToday: isLoadingChickens ? '...' : '${_summary.eggsToday}',
              ),

              const SizedBox(height: 24),

              Text(
                l10n.todaysOverview,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: StatisticCard(
                      title: l10n.feedRemaining,
                      value: isLoadingChickens
                          ? '...'
                          : '${_summary.feedRemaining.toStringAsFixed(1)} kg',
                      icon: Icons.grass,
                      color: AppColors.accent,
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: StatisticCard(
                      title: l10n.incomeToday,
                      value: isLoadingChickens
                          ? '...'
                          : '${_summary.incomeToday.toStringAsFixed(2)} ETB',
                      icon: Icons.attach_money,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: StatisticCard(
                      title: l10n.eggInventory,
                      value: isLoadingChickens
                          ? '...'
                          : '${_summary.eggInventory} eggs',
                      icon: Icons.inventory_2_outlined,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatisticCard(
                      title: l10n.expensesToday,
                      value: isLoadingChickens
                          ? '...'
                          : '${_summary.expensesToday.toStringAsFixed(2)} ETB',
                      icon: Icons.money_off,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Text(
                l10n.quickActions,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: QuickActionCard(
                      icon: Icons.egg_alt,
                      title: l10n.recordProduction,
                      onTap: () => _openAction(DashboardAction.production),
                    ),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: QuickActionCard(
                      icon: Icons.shopping_cart,
                      title: l10n.recordSale,
                      onTap: () => _openAction(DashboardAction.sale),
                    ),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: QuickActionCard(
                      icon: Icons.grass,
                      title: l10n.addFeed,
                      onTap: () => _openAction(DashboardAction.feed),
                    ),
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: QuickActionCard(
                      icon: Icons.money_off,
                      title: l10n.addExpense,
                      onTap: () => _openAction(DashboardAction.expense),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Weekly chart
              WeeklyChart(values: _summary.eggsLastSevenDays),

              const SizedBox(height: 24),

              Text(
                l10n.recentActivity,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 12),

              if (_summaryError != null)
                Center(
                  child: TextButton.icon(
                    onPressed: _loadSummary,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retryLoadingDashboard),
                  ),
                )
              else if (_summary.recentActivities.isEmpty)
                Text(l10n.noRecentActivity)
              else
                Column(
                  children: [
                    for (final activity in _summary.recentActivities) ...[
                      RecentActivityCard(
                        title: activity.title,
                        subtitle: activity.subtitle,
                        icon: Icons.history_rounded,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),

      // Navigation handled by MainPage; removed local bottomNavigationBar.
    );
  }
}
