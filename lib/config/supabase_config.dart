class SupabaseConfig {
  const SupabaseConfig._();

  static const String url = String.fromEnvironment('SUPABASE_URL');
  static const String _publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );
  static const String _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
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
