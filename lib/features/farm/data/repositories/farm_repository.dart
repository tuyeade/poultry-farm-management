import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/farm_overview.dart';

class FarmRepository {
  FarmRepository({SupabaseClient? client})
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<FarmOverview> getOverview() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return FarmOverview.empty;
    }

    final farm = await _findFarm(user.id);

    if (farm == null) {
      throw StateError('No farm found for this account.');
    }

    final farmId = farm['id'].toString();

    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final tomorrow = start.add(const Duration(days: 1));

    final batches = await _loadBatches(farmId);
    final production = await _loadProduction(farmId, start, tomorrow);
    final inventory = await _loadInventory(farmId);
    final feed = await _loadFeed(farmId);
    final medicines = await _loadMedicines(farmId);
    final vaccinations = await _loadVaccinations(farmId);

    return FarmOverview(
      farmName: farm['farm_name']?.toString() ?? 'My Farm',

      totalBirds: batches.fold(0, (sum, row) => sum + _int(row['quantity'])),

      activeBatches: batches.length,

      mortalityCount: batches.fold(
        0,
        (sum, row) => sum + _int(row['mortality_count']),
      ),

      initialBirds: batches.fold(
        0,
        (sum, row) =>
            sum + _int(row['quantity']) + _int(row['mortality_count']),
      ),

      eggsToday: production.fold(
        0,
        (sum, row) =>
            sum + _int(row['eggs_collected']) - _int(row['broken_eggs']),
      ),

      eggInventory: inventory.fold(
        0,
        (sum, row) => sum + _int(row['available_eggs']),
      ),

      feedStock: feed.fold(0.0, (sum, row) => sum + _double(row['quantity'])),

      medicineCount: medicines.length,

      vaccinationCount: vaccinations.length,
    );
  }

  // ============================================================
  // FARM
  // ============================================================

  Future<Map<String, dynamic>?> _findFarm(String userId) async {
    final farm = await _supabase
        .from('farms')
        .select('id, farm_name')
        .eq('owner_id', userId)
        .maybeSingle();

    if (farm == null) {
      return null;
    }

    return Map<String, dynamic>.from(farm);
  }
  // ============================================================
  // CHICKEN BATCHES
  // ============================================================

  Future<List<Map<String, dynamic>>> _loadBatches(String farmId) async {
    try {
      return _maps(
            await _supabase
                .from('chicken_batches')
                .select('quantity')
                .eq('farm_id', farmId),
          )
          .map((row) => {'quantity': row['quantity'], 'mortality_count': 0})
          .toList();
    } catch (_) {
      final response = await _supabase
          .from('chicken_batches')
          .select('quantity')
          .eq('farm_id', farmId);
      return _maps(response)
          .map((row) => {'quantity': row['quantity'], 'mortality_count': 0})
          .toList();
    }
  }

  // ============================================================
  // DAILY PRODUCTION
  // ============================================================

  Future<List<Map<String, dynamic>>> _loadProduction(
    String farmId,
    DateTime start,
    DateTime tomorrow,
  ) async {
    try {
      return _maps(
            await _supabase
                .from('daily_production')
                .select('eggs_collected, broken_eggs')
                .eq('farm_id', farmId)
                .gte('production_date', _date(start))
                .lt('production_date', _date(tomorrow)),
          )
          .map(
            (row) => {
              'eggs_collected': row['eggs_collected'],
              'broken_eggs': row['broken_eggs'],
            },
          )
          .toList();
    } catch (_) {
      final response = await _supabase
          .from('daily_production')
          .select('eggs_collected, broken_eggs')
          .eq('farm_id', farmId)
          .gte('production_date', _date(start))
          .lt('production_date', _date(tomorrow));
      return _maps(response)
          .map(
            (row) => {
              'eggs_collected': row['eggs_collected'],
              'broken_eggs': row['broken_eggs'],
            },
          )
          .toList();
    }
  }

  // ============================================================
  // EGG INVENTORY
  // ============================================================

  Future<List<Map<String, dynamic>>> _loadInventory(String farmId) async {
    try {
      return _maps(
        await _supabase
            .from('egg_inventory')
            .select('available_eggs')
            .eq('farm_id', farmId),
      ).map((row) => {'available_eggs': row['available_eggs']}).toList();
    } catch (_) {
      final response = await _supabase
          .from('egg_inventory')
          .select('available_eggs')
          .eq('farm_id', farmId);
      return _maps(
        response,
      ).map((row) => {'available_eggs': row['available_eggs']}).toList();
    }
  }

  // ============================================================
  // FEED
  // ============================================================

  Future<List<Map<String, dynamic>>> _loadFeed(String farmId) async {
    try {
      return _maps(
        await _supabase
            .from('feed_inventory')
            .select('quantity')
            .eq('farm_id', farmId),
      );
    } catch (_) {
      return _maps(
        await _supabase
            .from('feed_inventory')
            .select('quantity')
            .eq('farm_id', farmId),
      );
    }
  }

  // ============================================================
  // MEDICINES
  // ============================================================

  Future<List<Map<String, dynamic>>> _loadMedicines(String farmId) async {
    try {
      return _maps(
        await _supabase.from('medicines').select('id').eq('farm_id', farmId),
      );
    } catch (_) {
      return [];
    }
  }

  // ============================================================
  // VACCINATIONS
  // ============================================================

  Future<List<Map<String, dynamic>>> _loadVaccinations(String farmId) async {
    try {
      final batchResponse = await _supabase
          .from('chicken_batches')
          .select('id')
          .eq('farm_id', farmId);

      final batches = _maps(batchResponse);

      if (batches.isEmpty) {
        return [];
      }

      final batchIds = batches
          .map((batch) => batch['id'])
          .where((id) => id != null)
          .toList();

      final vaccinationResponse = await _supabase
          .from('vaccinations')
          .select('id, batch_id')
          .inFilter('batch_id', batchIds);

      return _maps(vaccinationResponse);
    } catch (_) {
      return [];
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static List<Map<String, dynamic>> _maps(dynamic value) {
    return (value as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  static int _int(dynamic value) {
    return (value as num?)?.toInt() ?? 0;
  }

  static double _double(dynamic value) {
    return (value as num?)?.toDouble() ?? 0;
  }

  static String _date(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
