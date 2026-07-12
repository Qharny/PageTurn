/// Supabase project credentials used to initialize the client in `main.dart`.
///
/// The anon key is safe to ship in the client — it only grants the access
/// allowed by the project's Row Level Security policies.
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = 'https://ingujinvlerljxoovcoi.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImluZ3VqaW52bGVybGp4b292Y29pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM4NzQwMzYsImV4cCI6MjA5OTQ1MDAzNn0.W_wjV9ubPP89U2TjIRrQxNrvhkF3RVI4zrI_3luyqBQ';
}
