import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'providers/auth_provider.dart' as app_auth;
import 'providers/product_provider.dart';
import 'core/theme.dart';
import 'screens/auth/auth_wrapper.dart';
import 'screens/setup/supabase_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.apiKey,
    );
  }
  runApp(MyApp(isSupabaseConfigured: SupabaseConfig.isConfigured));
}

class MyApp extends StatelessWidget {
  final bool isSupabaseConfigured;

  const MyApp({
    super.key,
    required this.isSupabaseConfigured,
  });

  @override
  Widget build(BuildContext context) {
    if (!isSupabaseConfigured) {
      return MaterialApp(
        title: 'Product Management',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const SupabaseSetupScreen(),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app_auth.AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
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
