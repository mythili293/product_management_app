import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/app_user.dart';
import '../models/auth_action_result.dart';
import '../models/model_utils.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<String?> get authStateChanges => _client.auth
      .onAuthStateChange
      .map((data) => data.session?.user.id)
      .distinct();

  Future<AuthActionResult> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      return const AuthActionResult.failure('Please fill in all required fields.');
    }

    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
        emailRedirectTo: kIsWeb ? null : SupabaseConfig.authCallbackUrl,
      );

      final requiresEmailConfirmation =
          response.user != null && response.session == null;

      return AuthActionResult.success(
        requiresEmailConfirmation
            ? 'Account created. Check your email to confirm your account.'
            : 'Account created successfully.',
        requiresEmailConfirmation: requiresEmailConfirmation,
      );
    } on AuthException catch (error) {
      return AuthActionResult.failure(error.message);
    } catch (_) {
      return const AuthActionResult.failure(
        'Unable to create your account right now.',
      );
    }
  }

  Future<AuthActionResult> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      return const AuthActionResult.failure('Please fill in all required fields.');
    }

    try {
      await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return const AuthActionResult.success('Signed in successfully.');
    } on AuthException catch (error) {
      return AuthActionResult.failure(error.message);
    } catch (_) {
      return const AuthActionResult.failure(
        'Unable to sign in right now.',
      );
    }
  }

  Future<AppUser?> getUserData(String uid) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser != null && currentUser.id == uid) {
      await _ensureProfile(currentUser);
    }

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return AppUser.fromMap(response);
  }

  Future<AuthActionResult> signInWithGoogle() async {
    try {
      final launched = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : SupabaseConfig.authCallbackUrl,
      );
      if (!launched) {
        return const AuthActionResult.failure(
          'Could not launch the Google sign-in flow.',
        );
      }

      return const AuthActionResult.success(
        'Continue with Google in the browser window that opened.',
        launchedExternalFlow: true,
      );
    } on AuthException catch (error) {
      return AuthActionResult.failure(error.message);
    } catch (_) {
      return const AuthActionResult.failure(
        'Unable to start Google sign-in right now.',
      );
    }
  }

  Future<AuthActionResult> sendPasswordResetEmail(String email) async {
    if (email.isEmpty) {
      return const AuthActionResult.failure('Enter your email address first.');
    }

    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb ? null : SupabaseConfig.authCallbackUrl,
      );
      return const AuthActionResult.success(
        'Password reset email sent. Check your inbox.',
      );
    } on AuthException catch (error) {
      return AuthActionResult.failure(error.message);
    } catch (_) {
      return const AuthActionResult.failure(
        'Unable to send the password reset email right now.',
      );
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> _ensureProfile(
    User user, {
    String? preferredName,
  }) async {
    final existingProfile = await _client
        .from('profiles')
        .select('role, name')
        .eq('id', user.id)
        .maybeSingle();

    final email = normalizeText(user.email);
    final metadata = user.userMetadata ?? {};
    final computedName = normalizeText(
      preferredName,
      fallback: normalizeText(
        metadata['name'],
        fallback: normalizeText(
          metadata['full_name'],
          fallback: email.contains('@') ? email.split('@').first : 'User',
        ),
      ),
    );

    await _client.from('profiles').upsert(
      {
        'id': user.id,
        'name': computedName,
        'email': email,
        'role': normalizeText(existingProfile?['role'], fallback: 'user'),
      },
      onConflict: 'id',
    );
  }
}
