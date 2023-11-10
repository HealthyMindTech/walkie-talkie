class AppConfig {
  static const String loginRedirect = String.fromEnvironment(
    'LOGIN_REDIRECT',
    defaultValue: 'io.supabase.flutter://login-callback/',
  );

  static const String supabaseUrl = String.fromEnvironment("SUPABASE_URL",
      defaultValue: 'https://rwlnvnijfocuqumwkgmv.supabase.co');
  static const String supabaseAnonkey = String.fromEnvironment(
      "SUPABASE_ANON_KEY",
      defaultValue:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ3bG52bmlqZm9jdXF1bXdrZ212Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTk2MzE1NTMsImV4cCI6MjAxNTIwNzU1M30._D39c2b4uPFIMvPTwRADc9lQQLEBr9G-gx_pq8Zh1AY');
}
