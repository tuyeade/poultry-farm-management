import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/report_overview.dart';

class ReportsRepository {
  ReportsRepository({SupabaseClient? client})
    : _supabase = client ?? Supabase.instance.client;
  final SupabaseClient _supabase;

  Future<ReportOverview> getOverview() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return ReportOverview.empty;
    List<Map<String, dynamic>> income;
    List<Map<String, dynamic>> expenses;
    List<Map<String, dynamic>> production;
    List<Map<String, dynamic>> batches;
    try {
      final farmId = await _farmId(user.id);
      final results = await Future.wait([
        _supabase
            .from('income')
            .select('category, amount, income_date, description')
            .eq('farm_id', farmId),
        _supabase
            .from('expenses')
            .select('category, amount, expense_date, description')
            .eq('farm_id', farmId),
        _supabase
            .from('daily_production')
            .select(
              'eggs_collected, broken_eggs, production_date, notes, batch_id',
            )
            .eq('farm_id', farmId),
        _supabase
            .from('chicken_batches')
            .select('batch_name, quantity, created_at')
            .eq('farm_id', farmId),
      ]);
      income = _maps(results[0]);
      expenses = _maps(results[1]);
      production = _maps(results[2]);
      batches = _maps(results[3])
          .map(
            (row) => {
              'batch_name': row['batch_name'],
              'quantity': row['quantity'],
              'mortality_count': 0,
              'created_at': row['created_at'],
            },
          )
          .toList();
    } catch (_) {
      final farmId = await _farmId(user.id);
      final results = await Future.wait([
        _supabase
            .from('income')
            .select('category, amount, income_date, description')
            .eq('farm_id', farmId),
        _supabase
            .from('expenses')
            .select('category, amount, expense_date, description, created_at')
            .eq('farm_id', farmId),
        _supabase
            .from('daily_production')
            .select('eggs_collected, broken_eggs, production_date')
            .eq('farm_id', farmId),
        _supabase
            .from('chicken_batches')
            .select('batch_name, quantity, created_at')
            .eq('farm_id', farmId),
      ]);
      income = _maps(results[0]);
      expenses = _maps(results[1]);
      production = _maps(results[2]);
      batches = _maps(results[3])
          .map(
            (row) => {
              'batch_name': row['batch_name'],
              'quantity': row['quantity'],
              'mortality_count': 0,
              'created_at': row['created_at'],
            },
          )
          .toList();
    }
    final financial = <ReportEntry>[
      ...income.map(
        (row) => ReportEntry(
          title: row['category']?.toString() ?? 'Income',
          subtitle: row['description']?.toString() ?? 'Income',
          value: '${_double(row['amount']).toStringAsFixed(2)} ETB',
          date: _date(row['income_date']),
        ),
      ),
      ...expenses.map(
        (row) => ReportEntry(
          title: row['category']?.toString() ?? 'Expense',
          subtitle: row['description']?.toString() ?? 'Expense',
          value: '${_double(row['amount']).toStringAsFixed(2)} ETB',
          date: _date(row['expense_date']),
        ),
      ),
    ]..sort((a, b) => b.date.compareTo(a.date));
    final productionEntries =
        production
            .map(
              (row) => ReportEntry(
                title: 'Egg production',
                subtitle:
                    '${_int(row['eggs_collected']) - _int(row['broken_eggs'])} usable eggs',
                value: '${_int(row['eggs_collected'])} collected',
                date: _date(row['production_date']),
              ),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    final chickenEntries =
        batches
            .map(
              (row) => ReportEntry(
                title: row['batch_name']?.toString() ?? 'Batch',
                subtitle: '${_int(row['mortality_count'])} mortality recorded',
                value: '${_int(row['quantity'])} birds',
                date: _date(row['created_at']),
              ),
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    final now = DateTime.now();
    final monthly = List<MonthlyReport>.generate(6, (index) {
      final month = DateTime(now.year, now.month - 5 + index, 1);
      final monthIncome = income
          .where((row) => _sameMonth(row['income_date'], month))
          .fold(0.0, (sum, row) => sum + _double(row['amount']));
      final monthExpenses = expenses
          .where((row) => _sameMonth(row['expense_date'], month))
          .fold(0.0, (sum, row) => sum + _double(row['amount']));
      final monthEggs = production
          .where((row) => _sameMonth(row['production_date'], month))
          .fold(
            0,
            (sum, row) =>
                sum + _int(row['eggs_collected']) - _int(row['broken_eggs']),
          );
      return MonthlyReport(
        label: DateFormat('MMM').format(month),
        income: monthIncome,
        expenses: monthExpenses,
        eggs: monthEggs,
      );
    });
    final breakdown = <String, double>{};
    for (final row in income) {
      final category = row['category']?.toString() ?? 'Other';
      breakdown[category] = (breakdown[category] ?? 0) + _double(row['amount']);
    }
    return ReportOverview(
      totalIncome: income.fold(0, (sum, row) => sum + _double(row['amount'])),
      totalExpenses: expenses.fold(
        0,
        (sum, row) => sum + _double(row['amount']),
      ),
      totalEggs: production.fold(
        0,
        (sum, row) =>
            sum + _int(row['eggs_collected']) - _int(row['broken_eggs']),
      ),
      totalChickens: batches.fold(0, (sum, row) => sum + _int(row['quantity'])),
      details: {
        'Financial Report': financial,
        'Production Report': productionEntries,
        'Chicken Report': chickenEntries,
      },
      monthly: monthly,
      revenueBreakdown: breakdown,
      mortalityRate: _mortalityRate(batches),
    );
  }

  Future<String> _farmId(String userId) async {
    final farm = await _supabase
        .from('farms')
        .select('id')
        .eq('owner_id', userId)
        .maybeSingle();
    if (farm == null) throw StateError('No farm is connected to this account.');
    return farm['id'].toString();
  }

  static List<Map<String, dynamic>> _maps(dynamic value) => (value as List)
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList();
  static int _int(dynamic value) => (value as num?)?.toInt() ?? 0;
  static double _mortalityRate(List<Map<String, dynamic>> batches) {
    final initial = batches.fold<int>(
      0,
      (sum, row) => sum + _int(row['quantity']) + _int(row['mortality_count']),
    );
    final deaths = batches.fold<int>(
      0,
      (sum, row) => sum + _int(row['mortality_count']),
    );
    return initial == 0 ? 0 : deaths / initial * 100;
  }

  static double _double(dynamic value) => (value as num?)?.toDouble() ?? 0;
  static DateTime _date(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();
  static bool _sameMonth(dynamic value, DateTime month) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    return date != null && date.year == month.year && date.month == month.month;
  }
}
