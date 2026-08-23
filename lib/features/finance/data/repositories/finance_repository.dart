import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/finance_overview.dart';

class FinanceRepository {
  FinanceRepository({SupabaseClient? client})
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<FinanceOverview> getOverview() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return FinanceOverview.empty;

    List<Map<String, dynamic>> income;
    List<Map<String, dynamic>> expenses;
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
      ]);
      income = _maps(results[0]);
      expenses = _maps(results[1]);
    } catch (_) {
      final results = await Future.wait([
        _supabase
            .from('sales')
            .select('product, quantity, unit_price, sale_date, created_at')
            .eq('user_id', user.id),
        _supabase
            .from('expenses')
            .select('category, amount, expense_date, description, created_at')
            .eq('user_id', user.id),
      ]);
      income = _maps(results[0])
          .map(
            (row) => {
              'category': row['product'],
              'amount': _double(row['quantity']) * _double(row['unit_price']),
              'income_date': row['sale_date'] ?? row['created_at'],
              'description': 'Sale income',
            },
          )
          .toList();
      expenses = _maps(results[1]);
    }
    final transactions = <FinanceTransaction>[
      ...income.map(_incomeTransaction),
      ...expenses.map(_expenseTransaction),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return FinanceOverview(
      totalIncome: income.fold(0, (sum, row) => sum + _double(row['amount'])),
      totalExpenses: expenses.fold(
        0,
        (sum, row) => sum + _double(row['amount']),
      ),
      transactions: transactions,
    );
  }

  Future<void> addIncome({
    required String category,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    final user = _requireUser();
    await _supabase.from('income').insert({
      'farm_id': await _farmId(user.id),
      'income_type': 'Sale',
      'category': category,
      'amount': amount,
      'income_date': _date(date),
      'description': description,
    });
  }

  Future<void> addExpense({
    required String category,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    final user = _requireUser();
    await _supabase.from('expenses').insert({
      'farm_id': await _farmId(user.id),
      'expense_type': 'Farm expense',
      'category': category,
      'amount': amount,
      'expense_date': _date(date),
      'description': description,
    });
  }

  User _requireUser() {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw StateError('You must be signed in to edit finance data.');
    }
    return user;
  }

  static FinanceTransaction _incomeTransaction(Map<String, dynamic> row) {
    return FinanceTransaction(
      title: row['category']?.toString() ?? 'Income',
      subtitle: row['description']?.toString() ?? 'Income',
      amount: _double(row['amount']),
      isIncome: true,
      date: _parseDate(row['income_date']),
    );
  }

  static FinanceTransaction _expenseTransaction(Map<String, dynamic> row) {
    return FinanceTransaction(
      title: row['category']?.toString() ?? 'Expense',
      subtitle: row['description']?.toString() ?? 'Farm expense',
      amount: _double(row['amount']),
      isIncome: false,
      date: _parseDate(row['expense_date'] ?? row['created_at']),
    );
  }

  static List<Map<String, dynamic>> _maps(dynamic value) => (value as List)
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList();

  static double _double(dynamic value) => (value as num?)?.toDouble() ?? 0;

  static DateTime _parseDate(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '') ?? DateTime.now();

  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<String> _farmId(String userId) async {
    final farm = await _supabase
        .from('farms')
        .select('id')
        .eq('owner_id', userId)
        .maybeSingle();
    if (farm == null) throw StateError('No farm is connected to this account.');
    return farm['id'].toString();
  }
}
