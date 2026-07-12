import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin accessor for the Supabase client initialized in `main.dart`.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;
}
