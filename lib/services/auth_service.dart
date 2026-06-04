import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get currentUserId => _client.auth.currentUser?.id;

  Stream<String?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((event) => event.session?.user.id);

  Future<AppUser?> signUpWithEmailAndPassword(
    String email,
    String password,
    String name, {
    String phone = '',
  }) async {
    if (email.isEmpty || password.isEmpty || phone.isEmpty) {
      throw Exception('Please fill in missing fields.');
    }

    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'phone': phone},
    );
    final user = response.user;
    if (user == null) throw Exception('Signup failed.');

    return getUserData(user.id);
  }

  Future<AppUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Please fill in missing fields.');
    }

    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) throw Exception('Login failed.');

    return getUserData(user.id);
  }

  Future<AppUser?> getUserData(String uid) async {
    final user = _client.auth.currentUser;
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (data != null) {
        return AppUser.fromMap(data, uid);
      }
    } catch (_) {
      // Fall through to auth metadata so the UI can still route cleanly.
    }

    if (user == null) return null;
    final metadata = user.userMetadata ?? {};
    return AppUser(
      userId: user.id,
      name: '${metadata['name'] ?? metadata['full_name'] ?? ''}',
      email: user.email ?? '',
      phone: '${metadata['phone'] ?? ''}',
      role: 'user',
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
