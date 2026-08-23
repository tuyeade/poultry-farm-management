import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/batch_model.dart';

class BatchRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all batches for the current user's farm.
  Future<List<BatchModel>> getBatches() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final farmId = await _farmId(user.id);

    final response = await _supabase
        .from('chicken_batches')
        .select()
        .eq('farm_id', farmId)
        .order('created_at', ascending: false);

    return response
        .map<BatchModel>((json) => BatchModel.fromMap(json))
        .toList();
  }

  /// Add a new batch.
  Future<void> addBatch({
    required String batchName,
    required String breed,
    required int birdCount,
    required int ageWeeks,
    required int mortalityCount,
    required String status,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final farmId = await _farmId(user.id);

    await _supabase.from('chicken_batches').insert({
      'farm_id': farmId,
      'batch_name': batchName,
      'breed': breed,
      'quantity': birdCount,
      'age_weeks': ageWeeks,
      'mortality_count': mortalityCount,
      'status': status,
    });
  }

  /// Update an existing batch.
  Future<void> updateBatch(BatchModel batch) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final farmId = await _farmId(user.id);

    final response = await _supabase
        .from('chicken_batches')
        .update({
          'batch_name': batch.batchName,
          'breed': batch.breed,
          'quantity': batch.birdCount,
          'age_weeks': batch.ageWeeks,
          'mortality_count': batch.mortalityCount,
          'status': batch.status,
          'updated_at': batch.updatedAt?.toIso8601String(),
        })
        .eq('id', batch.id)
        .eq('farm_id', farmId)
        .select();

    if (response.isEmpty) {
      throw Exception(
        'Batch was not updated. The batch may not belong to this farm.',
      );
    }
  }

  /// Delete a batch.
  Future<void> deleteBatch(String id) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final farmId = await _farmId(user.id);

    await _supabase
        .from('chicken_batches')
        .delete()
        .eq('id', id)
        .eq('farm_id', farmId);
  }

  /// Get total number of chickens.
  Future<int> getTotalChickens() async {
  final batches = await getBatches();

  return batches.fold<int>(
    0,
    (total, batch) => total + batch.birdCount,
  );
}

  /// Find the farm owned by the current user.
  Future<String> _farmId(String userId) async {
    final farm = await _supabase
        .from('farms')
        .select('id')
        .eq('owner_id', userId)
        .maybeSingle();

    if (farm == null) {
      throw Exception('No farm is connected to this account');
    }

    return farm['id'].toString();
  }
}

