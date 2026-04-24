import 'package:flutter/material.dart';

import '../../config/supabase_config.dart';
import '../../core/theme.dart';

class SupabaseSetupScreen extends StatelessWidget {
  final String? initializationError;

  const SupabaseSetupScreen({super.key, this.initializationError});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      initializationError == null
                          ? 'Supabase Setup Required'
                          : 'Supabase Connection Check Failed',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      initializationError == null
                          ? 'This build is ready for Supabase, but it still needs your project URL and API key before the app can connect.'
                          : 'The app found Supabase settings, but startup failed before the client could connect cleanly.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (initializationError != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Startup error',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _commandBlock(initializationError!),
                    ],
                    const SizedBox(height: 20),
                    _commandBlock(
                      'flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co '
                      '--dart-define=SUPABASE_PUBLISHABLE_KEY=your_publishable_key',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Configured project URL',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _commandBlock(SupabaseConfig.url),
                    const SizedBox(height: 16),
                    Text(
                      'Mobile redirect URL',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _commandBlock(SupabaseConfig.authCallbackUrl),
                    const SizedBox(height: 16),
                    Text(
                      'Run every SQL file in `supabase/migrations/` in date order before signing in.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    _commandBlock(
                      '1. supabase/migrations/20260423_initial_schema.sql\n'
                      '2. supabase/migrations/20260424_add_is_available.sql',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _commandBlock(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: SelectableText(
        text,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }
}
