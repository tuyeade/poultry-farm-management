import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/localization/generated/app_localizations.dart';

class EggInventoryPage extends StatefulWidget {
  const EggInventoryPage({super.key});

  @override
  State<EggInventoryPage> createState() => _EggInventoryPageState();
}

class _EggInventoryPageState extends State<EggInventoryPage> {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _loading = true;

  int _availableEggs = 0;
  int _collectedEggs = 0;
  int _damagedEggs = 0;

  int _soldThisWeek = 0;
  double _revenue = 0;

  List<Map<String, dynamic>> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  // ============================================================
  // FARM
  // ============================================================

  Future<String> _getFarmId() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('You must be signed in.');
    }

    final farm = await _supabase
        .from('farms')
        .select('id')
        .eq('owner_id', user.id)
        .maybeSingle();

    if (farm == null) {
      throw Exception('No farm is connected to this account.');
    }

    return farm['id'].toString();
  }

  // ============================================================
  // LOAD INVENTORY FROM SUPABASE
  // ============================================================
  Future<void> _loadInventory() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
    });

    try {
      final farmId = await _getFarmId();

      final results = await Future.wait([
        // EGG INVENTORY
        _supabase
            .from('egg_inventory')
            .select('available_eggs')
            .eq('farm_id', farmId),

        // DAILY PRODUCTION
        _supabase
            .from('daily_production')
            .select('production_date, eggs_collected, broken_eggs')
            .eq('farm_id', farmId)
            .order('production_date', ascending: false),

        // EGG SALES
        _supabase
            .from('egg_sales')
            .select('quantity, total_price, sale_date')
            .eq('farm_id', farmId)
            .order('sale_date', ascending: false),
      ]);

      final inventory = List<Map<String, dynamic>>.from(results[0]);
      final production = List<Map<String, dynamic>>.from(results[1]);
      final sales = List<Map<String, dynamic>>.from(results[2]);

      final availableEggs = inventory.fold<int>(
        0,
        (sum, row) => sum + _toInt(row['available_eggs']),
      );

      final collectedEggs = production.fold<int>(
        0,
        (sum, row) => sum + _toInt(row['eggs_collected']),
      );

      final damagedEggs = production.fold<int>(
        0,
        (sum, row) => sum + _toInt(row['broken_eggs']),
      );

      final weekStart = DateTime.now().subtract(const Duration(days: 7));

      final soldThisWeek = sales.fold<double>(0, (sum, row) {
        final date = DateTime.tryParse(row['sale_date']?.toString() ?? '');

        if (date == null || date.isBefore(weekStart)) {
          return sum;
        }

        return sum + _toDouble(row['quantity']);
      });

      final revenue = sales.fold<double>(
        0,
        (sum, row) => sum + _toDouble(row['total_price']),
      );

      final transactions = production.take(5).map((row) {
        return {
          'date': row['production_date'],
          'collected': _toInt(row['eggs_collected']),
          'broken': _toInt(row['broken_eggs']),
        };
      }).toList();

      if (!mounted) return;

      setState(() {
        _availableEggs = availableEggs;
        _collectedEggs = collectedEggs;
        _damagedEggs = damagedEggs;
        _soldThisWeek = soldThisWeek.round();
        _revenue = revenue;
        _recentTransactions = List<Map<String, dynamic>>.from(transactions);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.unableToLoadEggInventory}: $error',
          ),
        ),
      );
    }
  }

  int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new),
            color: AppColors.textPrimary,
          ),
        ),
        title: Text(
          l10n.eggInventoryTitle,
          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: _loadInventory,
            icon: const Icon(Icons.refresh),
            color: AppColors.primary,
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadInventory,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                children: [
                  _buildSummaryGrid(),

                  const SizedBox(height: 22),

                  _buildSectionTitle(
                    AppLocalizations.of(context)!.inventoryBreakdown,
                  ),

                  const SizedBox(height: 12),

                  _buildBreakdownCard(),

                  const SizedBox(height: 22),

                  _buildSectionTitle(
                    AppLocalizations.of(context)!.recentTransactions,
                  ),

                  const SizedBox(height: 12),

                  _buildTransactionsCard(),
                ],
              ),
      ),
    );
  }

  // ============================================================
  // SUMMARY GRID
  // ============================================================

  Widget _buildSummaryGrid() {
    final l10n = AppLocalizations.of(context)!;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.45,
      children: [
        _summaryCard(
          icon: Icons.inventory_2_outlined,
          iconColor: Colors.green,
          title: l10n.available,
          value: _formatNumber(_availableEggs),
        ),
        _summaryCard(
          icon: Icons.trending_up,
          iconColor: Colors.green,
          title: l10n.soldThisWeek,
          value: _formatNumber(_soldThisWeek),
        ),

        _summaryCard(
          icon: Icons.error_outline,
          iconColor: Colors.red,
          title: l10n.damaged,
          value: _formatNumber(_damagedEggs),
        ),

        _summaryCard(
          icon: Icons.attach_money,
          iconColor: Colors.amber,
          title: l10n.revenue,
          value: 'ETB ${_formatMoney(_revenue)}',
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: iconColor),
          Text(title, style: AppTextStyles.bodySmall),
          Text(value, style: AppTextStyles.titleLarge),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard() {
    final totalCollected = _collectedEggs;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _breakdownRow(
            title: AppLocalizations.of(context)!.collected,
            value: totalCollected,
            percentage: totalCollected == 0
                ? 0
                : totalCollected / totalCollected,
            showDivider: true,
          ),

          _breakdownRow(
            title: AppLocalizations.of(context)!.availableEggs,
            value: _availableEggs,
            percentage: totalCollected == 0
                ? 0
                : _availableEggs / totalCollected,
            showDivider: true,
          ),

          _breakdownRow(
            title: AppLocalizations.of(context)!.crackedDamaged,
            value: _damagedEggs,
            percentage: totalCollected == 0 ? 0 : _damagedEggs / totalCollected,
            showDivider: false,
          ),
        ],
      ),
    );
  }
  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleLarge.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ============================================================
  // BREAKDOWN
  // ============================================================

  Widget _breakdownRow({
    required String title,
    required int value,
    required double percentage,
    required bool showDivider,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.border))
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              Text(
                _formatNumber(value),
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage.clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: AppColors.border.withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // RECENT TRANSACTIONS
  // ============================================================

  Widget _buildTransactionsCard() {
    if (_recentTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 42,
              color: AppColors.textSecondary,
            ),

            const SizedBox(height: 10),

            Text(
              AppLocalizations.of(context)!.noRecentTransactions,
              style: AppTextStyles.titleMedium,
            ),

            const SizedBox(height: 4),

            Text(
              AppLocalizations.of(context)!.dailyProductionRecordsHint,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(_recentTransactions.length, (index) {
          final transaction = _recentTransactions[index];

          final collected = _toInt(transaction['collected']);

          final broken = _toInt(transaction['broken']);

          final date = DateTime.tryParse(transaction['date']?.toString() ?? '');

          final dateText = date == null ? '' : _transactionDate(date);

          return _transactionRow(
            icon: Icons.trending_up,
            iconColor: Colors.green,
            title: AppLocalizations.of(context)!.dailyProduction,
            subtitle: dateText,
            value:
                '+${_formatNumber(collected)} ${AppLocalizations.of(context)!.eggs}',
            secondary: broken > 0
                ? AppLocalizations.of(context)!.damagedCount(broken)
                : null,
            showDivider: index != _recentTransactions.length - 1,
          );
        }),
      ),
    );
  }

  Widget _transactionRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String value,
    String? secondary,
    required bool showDivider,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.border))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  secondary == null ? subtitle : '$subtitle • $secondary',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }

  String _formatMoney(double amount) {
    return NumberFormat('#,##0').format(amount);
  }

  String _transactionDate(DateTime date) {
    final today = DateTime.now();

    final dateOnly = DateTime(date.year, date.month, date.day);

    final todayOnly = DateTime(today.year, today.month, today.day);

    final difference = todayOnly.difference(dateOnly).inDays;

    if (difference == 0) {
      return AppLocalizations.of(context)!.today;
    }

    if (difference == 1) {
      return AppLocalizations.of(context)!.yesterday;
    }

    return DateFormat('MMM d').format(date);
  }
}
