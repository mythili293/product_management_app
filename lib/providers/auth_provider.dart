import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  AppUser? _appUser;
  bool _isLoading = false;

  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  bool get isAdmin => _appUser?.role == 'admin';

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    final currentUserId = _authService.currentUserId;
    if (currentUserId != null) {
      _appUser = await _authService.getUserData(currentUserId);
      notifyListeners();
    }

    _authService.authStateChanges.listen((String? userUid) async {
      if (userUid != null) {
        _appUser = await _authService.getUserData(userUid);
      } else {
        _appUser = null;
      }
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _appUser = await _authService.signInWithEmailAndPassword(email, password);
      // Wait to simulate network hop
      await Future.delayed(const Duration(milliseconds: 600));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false; // Error handled by Screen
    }
  }

  Future<bool> signUp(
    String email,
    String password,
    String name, {
    String phone = '',
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      _appUser = await _authService.signUpWithEmailAndPassword(
        email,
        password,
        name,
        phone: phone,
      );
      // Simulate network hop
      await Future.delayed(const Duration(milliseconds: 600));
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _appUser = null;
    await _authService.signOut();
    notifyListeners();
  }
}
