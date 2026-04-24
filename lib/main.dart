import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'providers/admin_provider.dart';
import 'providers/auth_provider.dart' as app_auth;
import 'providers/product_provider.dart';
import 'core/theme.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/setup/supabase_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? initializationError;

  if (SupabaseConfig.isConfigured) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.apiKey,
        authOptions: FlutterAuthClientOptions(
          // Supabase recommends PKCE for deep-link based mobile auth.
          // We keep implicit flow on web to avoid the browser reload
          // code-verifier issue noted in the existing setup.
          authFlowType: kIsWeb ? AuthFlowType.implicit : AuthFlowType.pkce,
        ),
      );
    } catch (error) {
      initializationError = error.toString();
    }
  }

  runApp(
    MyApp(
      isSupabaseConfigured: SupabaseConfig.isConfigured,
      initializationError: initializationError,
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isSupabaseConfigured;
  final String? initializationError;

  const MyApp({
    super.key,
    required this.isSupabaseConfigured,
    this.initializationError,
  });

  @override
  Widget build(BuildContext context) {
    final showSetupScreen =
        !isSupabaseConfigured || initializationError != null;

    if (showSetupScreen) {
      return MaterialApp(
        title: 'Product Management',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: SupabaseSetupScreen(initializationError: initializationError),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'Product Management',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}
