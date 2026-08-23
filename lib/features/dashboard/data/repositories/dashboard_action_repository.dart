import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardActionRepository {
  DashboardActionRepository({SupabaseClient? client})
    : _supabase = client ?? Supabase.instance.client;
  final SupabaseClient _supabase;

  Future<void> recordProduction({
    required int quantity,
    required int brokenQuantity,
    String? notes,
  }) async {
    final user = _requireUser();
    final farmId = await _farmId(user.id);
    final batch = await _supabase
        .from('chicken_batches')
        .select('id')
        .eq('farm_id', farmId)
        .limit(1)
        .maybeSingle();
    if (batch == null) {
      throw StateError('Create a chicken batch before recording production.');
    }
    await _supabase.from('daily_production').insert({
      'farm_id': farmId,
      'batch_id': batch['id'],
      'production_date': _date(DateTime.now()),
      'eggs_collected': quantity,
      'broken_eggs': brokenQuantity,
      'dirty_eggs': 0,
      'eggs_used_home': 0,
      'eggs_incubated': 0,
      'notes': notes?.trim(),
    });
  }

  Future<void> recordSale({
    required double quantity,
    required double unitPrice,
    String? notes,
  }) async {
    final user = _requireUser();
    await _supabase.from('income').insert({
      'farm_id': await _farmId(user.id),
      'income_type': 'Sale',
      'category': 'Eggs',
      'amount': quantity * unitPrice,
      'income_date': _date(DateTime.now()),
      'description': notes?.trim(),
    });
  }

  Future<void> addFeed({
    required String feedType,
    required double quantity,
    required double unitCost,
  }) async {
    final user = _requireUser();
    await _supabase.from('feed_inventory').insert({
      'farm_id': await _farmId(user.id),
      'feed_name': feedType.trim(),
      'quantity': quantity,
      'unit': 'kg',
      'cost': unitCost,
      'purchase_date': _date(DateTime.now()),
    });
  }

  Future<void> recordExpense({
    required String category,
    required double amount,
    String? description,
  }) async {
    final user = _requireUser();
    await _supabase.from('expenses').insert({
      'farm_id': await _farmId(user.id),
      'expense_type': 'Farm expense',
      'category': category.trim(),
      'amount': amount,
      'expense_date': _date(DateTime.now()),
      'description': description?.trim(),
    });
  }

  Future<void> recordIncome({
    required String category,
    required double amount,
    String? description,
  }) async {
    final user = _requireUser();
    await _supabase.from('income').insert({
      'farm_id': await _farmId(user.id),
      'income_type': 'Sale',
      'category': category.trim(),
      'amount': amount,
      'income_date': _date(DateTime.now()),
      'description': description?.trim(),
    });
  }

  User _requireUser() {
    final user = _supabase.auth.currentUser;
    if (user == null) throw StateError('Please sign in to continue.');
    return user;
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

  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
