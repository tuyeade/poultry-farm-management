import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/dashboard_summary.dart';

class DashboardRepository {
  DashboardRepository({SupabaseClient? client})
    : _supabase = client ?? Supabase.instance.client;
  final SupabaseClient _supabase;

  Future<DashboardSummary> getSummary() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return DashboardSummary.empty;
    final farmId = await _farmId(user.id);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 6));
    final tomorrow = today.add(const Duration(days: 1));
    final results = await Future.wait([
      _supabase
          .from('chicken_batches')
          .select('batch_name, quantity, created_at')
          .eq('farm_id', farmId),
      _supabase
          .from('daily_production')
          .select('eggs_collected, production_date')
          .eq('farm_id', farmId)
          .gte('production_date', _date(start))
          .lt('production_date', _date(tomorrow)),
      _supabase.from('feed_inventory').select('quantity').eq('farm_id', farmId),
      _loadInventory(farmId, user.id),
      _supabase
          .from('income')
          .select('category, amount, income_date')
          .eq('farm_id', farmId)
          .gte('income_date', _date(today))
          .lt('income_date', _date(tomorrow)),
      _supabase
          .from('expenses')
          .select('category, amount, expense_date')
          .eq('farm_id', farmId)
          .gte('expense_date', _date(today))
          .lt('expense_date', _date(tomorrow)),
    ]);
    final batches = _maps(results[0]);
    final production = _maps(results[1]);
    final feed = _maps(results[2]);
    final inventory = _maps(results[3]);
    final income = _maps(results[4]);
    final expenses = _maps(results[5]);
    final eggsByDay = List<int>.filled(7, 0);
    for (final row in production) {
      final date = DateTime.tryParse(row['production_date']?.toString() ?? '');
      if (date == null) continue;
      final index = DateTime(
        date.year,
        date.month,
        date.day,
      ).difference(start).inDays;
      if (index >= 0 && index < 7) {
        eggsByDay[index] += _int(row['eggs_collected']);
      }
    }
    final activities = <DashboardActivity>[
      ...production.map(
        (row) => DashboardActivity(
          title: 'Egg production recorded',
          subtitle: '${_int(row['eggs_collected'])} eggs',
          date: _dateTime(row['production_date']),
        ),
      ),
      ...income.map(
        (row) => DashboardActivity(
          title: 'Income recorded',
          subtitle:
              '${row['category'] ?? 'Income'} - ${_money(row['amount'])} ETB',
          date: _dateTime(row['income_date']),
        ),
      ),
      ...expenses.map(
        (row) => DashboardActivity(
          title: 'Expense recorded',
          subtitle:
              '${row['category'] ?? 'Expense'} - ${_money(row['amount'])} ETB',
          date: _dateTime(row['expense_date']),
        ),
      ),
      ...batches.map(
        (row) => DashboardActivity(
          title: 'Batch added',
          subtitle:
              '${row['batch_name'] ?? 'Batch'} - ${_int(row['quantity'])} birds',
          date: _dateTime(row['created_at']),
        ),
      ),
    ]..sort((a, b) => b.date.compareTo(a.date));
    return DashboardSummary(
      totalBirds: batches.fold(0, (sum, row) => sum + _int(row['quantity'])),
      activeFarms: 1,
      eggsToday: eggsByDay.last,
      feedRemaining: feed.fold(
        0.0,
        (sum, row) => sum + _double(row['quantity']),
      ),
      eggInventory: inventory.fold(
        0,
        (sum, row) => sum + _int(row['available_eggs']),
      ),
      incomeToday: income.fold(0.0, (sum, row) => sum + _double(row['amount'])),
      expensesToday: expenses.fold(
        0.0,
        (sum, row) => sum + _double(row['amount']),
      ),
      eggsLastSevenDays: eggsByDay,
      recentActivities: activities.take(5).toList(),
    );
  }

  Future<String> _farmId(String userId) async {
    Map<String, dynamic>? farm;
    try {
      farm = await _supabase
          .from('farms')
          .select('id')
          .eq('owner_id', userId)
          .maybeSingle();
    } catch (_) {}
    farm ??= await _supabase
        .from('farms')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();
    if (farm == null) throw StateError('No farm is connected to this account.');
    return farm['id'].toString();
  }

  Future<List<Map<String, dynamic>>> _loadInventory(
    String farmId,
    String userId,
  ) async {
    try {
      return _maps(
        await _supabase
            .from('egg_inventory')
            .select('available_eggs')
            .eq('farm_id', farmId),
      );
    } catch (_) {
      final rows = _maps(
        await _supabase
            .from('egg_inventory')
            .select('available_eggs')
            .eq('farm_id', farmId),
      );
      return rows
          .map((row) => {'available_eggs': row['available_eggs']})
          .toList();
    }
  }

  static List<Map<String, dynamic>> _maps(dynamic value) => (value as List)
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList();
  static int _int(dynamic value) => (value as num?)?.toInt() ?? 0;
  static double _double(dynamic value) => (value as num?)?.toDouble() ?? 0;
  static String _money(dynamic value) => _double(value).toStringAsFixed(2);
  static DateTime _dateTime(dynamic value) =>
      DateTime.tryParse(value?.toString() ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);
  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
