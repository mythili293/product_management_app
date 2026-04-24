class SupabaseConfig {
  const SupabaseConfig._();

  // Project URL — override at build time with --dart-define=SUPABASE_URL=...
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://bvavndpnipsisqezlkiz.supabase.co',
  );

  static const String _publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  // Anon key — override at build time with --dart-define=SUPABASE_ANON_KEY=...
  static const String _anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
        '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ2YXZuZHBuaXBzaXNxZXpsa2l6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY5NTA5MDQsImV4cCI6MjA5MjUyNjkwNH0'
        '.DqMakaTmvMjrsrsapDYdTqF3qD1kroRkxrY-M802Ah0',
  );

  static const String redirectScheme = String.fromEnvironment(
    'SUPABASE_REDIRECT_SCHEME',
    defaultValue: 'productmanagementapp',
  );

  static const String redirectHost = String.fromEnvironment(
    'SUPABASE_REDIRECT_HOST',
    defaultValue: 'login-callback',
  );

  static String get apiKey =>
      _publishableKey.isNotEmpty ? _publishableKey : _anonKey;

  static bool get isConfigured => url.isNotEmpty && apiKey.isNotEmpty;

  static String get authCallbackUrl => '$redirectScheme://$redirectHost/';
}

