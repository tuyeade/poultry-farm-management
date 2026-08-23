import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/localization/generated/app_localizations.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../data/models/finance_overview.dart';
import '../../data/repositories/finance_repository.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  final FinanceRepository _repository = FinanceRepository();

  late Future<FinanceOverview> _future;

  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _repository.getOverview();
  }

  Future<void> _refresh() async {
    if (!mounted) return;

    final future = _repository.getOverview();

    setState(() {
      _future = future;
    });

    await future;
  }

  // ------------------------------------------------------------
  // RECORD INCOME / EXPENSE
  // ------------------------------------------------------------

  Future<void> _record(bool income) async {
    final l10n = AppLocalizations.of(context)!;
    final values = await _financeDialog(
      context,
      income: income,
    );

    if (values == null) return;

    try {
      if (income) {
        await _repository.addIncome(
          category: values.category,
          amount: values.amount,
          date: values.date,
          description: values.description,
        );
      } else {
        await _repository.addExpense(
          category: values.category,
          amount: values.amount,
          date: values.date,
          description: values.description,
        );
      }

      if (!mounted) return;

      await _refresh();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            income
                ? l10n.incomeRecordedSuccessfully
                : l10n.expenseRecordedSuccessfully,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.unableToSaveRecord(error.toString())),
        ),
      );
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.finance,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.textLight,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
      ),
      body: FutureBuilder<FinanceOverview>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.unableToLoadFinanceData),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          final overview =
              snapshot.data ?? FinanceOverview.empty;

          final shown = _tab == 0
              ? overview.transactions
              : overview.transactions
                  .where(
                    (item) =>
                        _tab == 1 ? item.isIncome : !item.isIncome,
                  )
                  .toList();

          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _hero(overview),

                  const SizedBox(height: 18),

                  _tabs(),

                  const SizedBox(height: 16),

                  _metricGrid(overview),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _action(
                          l10n.recordIncome,
                          Icons.add,
                          true,
                          () => _record(true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _action(
                          l10n.recordExpense,
                          Icons.remove,
                          false,
                          () => _record(false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  Text(
                    _tab == 0
                        ? l10n.recentTransactions
                        : _tab == 1 ? l10n.incomeRecords : l10n.expenseRecords,
                    style: AppTextStyles.titleLarge,
                  ),

                  const SizedBox(height: 10),

                  if (shown.isEmpty)
                    _empty()
                  else
                    ...shown.take(10).map(_transaction),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // HERO
  // ------------------------------------------------------------

  Widget _hero(FinanceOverview overview) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMMM yyyy').format(DateTime.now()),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textLight.withValues(
                alpha: 0.8,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Card(
            color: AppColors.textLight.withValues(
              alpha: 0.18,
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: AppColors.textLight.withValues(
                  alpha: 0.3,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.netProfit,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textLight.withValues(
                        alpha: 0.85,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${_money(overview.balance)} ETB',
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.textLight,
                      fontSize: 30,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _heroStat(
                          AppLocalizations.of(context)!.income,
                          overview.totalIncome,
                        ),
                      ),
                      Expanded(
                        child: _heroStat(
                          AppLocalizations.of(context)!.expenses,
                          overview.totalExpenses,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroStat(
    String label,
    double value,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textLight.withValues(
              alpha: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${_money(value)} ETB',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.textLight,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // TABS
  // ------------------------------------------------------------

  Widget _tabs() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _tabButton(AppLocalizations.of(context)!.overview, 0),
          _tabButton(AppLocalizations.of(context)!.income, 1),
          _tabButton(AppLocalizations.of(context)!.expenses, 2),
        ],
      ),
    );
  }

  Widget _tabButton(
    String label,
    int index,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: TextButton(
          onPressed: () {
            setState(() {
              _tab = index;
            });
          },
          style: TextButton.styleFrom(
            backgroundColor: _tab == index
                ? AppColors.primary
                : Colors.transparent,
            foregroundColor: _tab == index
                ? AppColors.textLight
                : AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // METRICS
  // ------------------------------------------------------------

  Widget _metricGrid(
    FinanceOverview overview,
  ) {
    final egg = overview.transactions
        .where(
          (item) =>
              item.isIncome &&
              item.title
                  .toLowerCase()
                  .contains('egg'),
        )
        .fold(
          0.0,
          (sum, item) => sum + item.amount,
        );

    final bird = overview.transactions
        .where(
          (item) =>
              item.isIncome &&
              !item.title
                  .toLowerCase()
                  .contains('egg'),
        )
        .fold(
          0.0,
          (sum, item) => sum + item.amount,
        );

    final feed = overview.transactions
        .where(
          (item) =>
              !item.isIncome &&
              item.title
                  .toLowerCase()
                  .contains('feed'),
        )
        .fold(
          0.0,
          (sum, item) => sum + item.amount,
        );

    final labour = overview.transactions
        .where(
          (item) =>
              !item.isIncome &&
              (item.title
                      .toLowerCase()
                      .contains('labour') ||
                  item.title
                      .toLowerCase()
                      .contains('salary')),
        )
        .fold(
          0.0,
          (sum, item) => sum + item.amount,
        );

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.45,
      children: [
        _metric(
          'Egg Sales',
          egg,
          Icons.egg_outlined,
          AppColors.secondary,
        ),
        _metric(
          'Bird Sales',
          bird,
          Icons.trending_up,
          AppColors.success,
        ),
        _metric(
          'Feed Cost',
          feed,
          Icons.grass_outlined,
          AppColors.accent,
        ),
        _metric(
          'Labour',
          labour,
          Icons.person_outline,
          AppColors.primary,
        ),
      ],
    );
  }

  Widget _metric(
    String title,
    double value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 19,
              ),
            ),

            const Spacer(),

            Text(
              '${_money(value)} ETB',
              style: AppTextStyles.titleMedium,
            ),

            Text(
              title,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ACTION BUTTON
  // ------------------------------------------------------------

  Widget _action(
    String label,
    IconData icon,
    bool primary,
    VoidCallback onTap,
  ) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary
              ? AppColors.primary
              : AppColors.primary.withValues(
                  alpha: 0.1,
                ),
          foregroundColor: primary
              ? AppColors.textLight
              : AppColors.error,
          elevation: 0,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // TRANSACTION
  // ------------------------------------------------------------

  Widget _transaction(
    FinanceTransaction item,
  ) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: AppColors.border,
        ),
      ),
      child: ListTile(
        leading: Icon(
          item.isIncome
              ? Icons.arrow_downward
              : Icons.arrow_upward,
          color: item.isIncome
              ? AppColors.success
              : AppColors.error,
        ),
        title: Text(
          item.title,
          style: AppTextStyles.titleMedium,
        ),
        subtitle: Text(
          '${item.subtitle} - ${DateFormat.yMMMd().format(item.date)}',
          style: AppTextStyles.bodySmall,
        ),
        trailing: Text(
          '${item.isIncome ? '+' : '-'}${_money(item.amount)} ETB',
          style: AppTextStyles.titleMedium.copyWith(
            color: item.isIncome
                ? AppColors.success
                : AppColors.error,
          ),
        ),
      ),
    );
  }

  Widget _empty() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(AppLocalizations.of(context)!.noRecordsFound),
        ),
      ),
    );
  }

  static String _money(double value) {
    return value.toStringAsFixed(2);
  }
}

// ============================================================
// FINANCE VALUES
// ============================================================

class _FinanceValues {
  final String category;
  final double amount;
  final DateTime date;
  final String? description;

  const _FinanceValues({
    required this.category,
    required this.amount,
    required this.date,
    this.description,
  });
}

// ============================================================
// FINANCE DIALOG
// ============================================================

Future<_FinanceValues?> _financeDialog(
  BuildContext context, {
  required bool income,
}) {
  return showDialog<_FinanceValues>(
    context: context,
    builder: (_) {
      return _FinanceDialog(
        income: income,
      );
    },
  );
}

// ============================================================
// FINANCE DIALOG WIDGET
// ============================================================

class _FinanceDialog extends StatefulWidget {
  final bool income;

  const _FinanceDialog({
    required this.income,
  });

  @override
  State<_FinanceDialog> createState() =>
      _FinanceDialogState();
}

class _FinanceDialogState
    extends State<_FinanceDialog> {
  late final TextEditingController
      _categoryController;

  late final TextEditingController
      _amountController;

  late final TextEditingController
      _descriptionController;

  DateTime _date = DateTime.now();

  final bool _saving = false;

  @override
  void initState() {
    super.initState();

    _categoryController =
        TextEditingController();

    _amountController =
        TextEditingController();

    _descriptionController =
        TextEditingController();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  // ----------------------------------------------------------
  // DATE
  // ----------------------------------------------------------

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDate: _date,
    );

    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      _date = selected;
    });
  }

  // ----------------------------------------------------------
  // SAVE
  // ----------------------------------------------------------

  void _save() {
    if (_saving) return;

    final name =
        _categoryController.text.trim();

    final amount =
        double.tryParse(
              _amountController.text.trim(),
            ) ??
            0;

    final description =
        _descriptionController.text.trim();

    // Validate category
    if (name.isEmpty) {
      _showError(
        widget.income
          ? '${AppLocalizations.of(context)!.product} ${AppLocalizations.of(context)!.required.toLowerCase()}'
          : '${AppLocalizations.of(context)!.category} ${AppLocalizations.of(context)!.required.toLowerCase()}',
      );
      return;
    }

    // Validate amount
    if (amount <= 0) {
      _showError(
        AppLocalizations.of(context)!.enterValidAmount,
      );
      return;
    }

    // Close dialog and return values
    Navigator.of(context).pop(
      _FinanceValues(
        category: name,
        amount: amount,
        date: _date,
        description:
            description.isEmpty
                ? null
                : description,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ----------------------------------------------------------
  // BUILD DIALOG
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(
        widget.income
            ? l10n.recordIncome
            : l10n.recordExpense,
      ),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // CATEGORY / PRODUCT
            TextField(
              controller: _categoryController,
              textCapitalization:
                  TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: widget.income
                    ? l10n.product
                    : l10n.category,
                hintText: widget.income
                    ? l10n.productHint
                    : l10n.categoryHint,
                prefixIcon: const Icon(
                  Icons.category_outlined,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // AMOUNT
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.amountEur,
                hintText: '0.00',
                prefixIcon: Icon(
                  Icons.payments_outlined,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // DESCRIPTION
            TextField(
              controller: _descriptionController,
              textCapitalization:
                  TextCapitalization.sentences,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: l10n.description,
                hintText: l10n.optional,
                prefixIcon: const Icon(
                  Icons.notes_outlined,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // DATE
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _selectDate,
                icon: const Icon(
                  Icons.calendar_today,
                ),
                label: Text(
                  DateFormat.yMMMd()
                      .format(_date),
                ),
              ),
            ),
          ],
        ),
      ),

      // ------------------------------------------------------
      // ACTIONS
      // ------------------------------------------------------

      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(l10n.cancel),
        ),

        ElevatedButton(
          onPressed: _save,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}