import 'package:supabase_flutter/supabase_flutter.dart';

class FarmService {
  static final SupabaseClient _supabase =
      Supabase.instance.client;

  /// Returns the farm ID belonging to the currently
  /// authenticated user.
  static Future<String?> getCurrentFarmId() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final response = await _supabase
        .from('farms')
        .select('id')
        .eq('owner_id', user.id)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return response['id'] as String?;
  }

  /// Returns the complete farm belonging to the
  /// currently authenticated user.
  static Future<Map<String, dynamic>?> getCurrentFarm() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final response = await _supabase
        .from('farms')
        .select()
        .eq('owner_id', user.id)
        .maybeSingle();

    return response;
  }
}