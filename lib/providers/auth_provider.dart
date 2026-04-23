import 'dart:async';

import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/auth_action_result.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  AppUser? _appUser;
  bool _isLoading = false;
  bool _isBootstrapping = true;
  StreamSubscription<String?>? _authSubscription;
  String? _lastMessage;

  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  bool get isBootstrapping => _isBootstrapping;
  bool get isAdmin => _appUser?.role == 'admin';
  String? get lastMessage => _lastMessage;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _authSubscription = _authService.authStateChanges.listen((String? userUid) async {
      if (userUid != null) {
        _appUser = await _authService.getUserData(userUid);
      } else {
        _appUser = null;
      }
      _isBootstrapping = false;
      notifyListeners();
    });
  }

  Future<AuthActionResult> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    final result = await _authService.signInWithEmailAndPassword(email, password);
    _lastMessage = result.message;
    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<AuthActionResult> signUp(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();
    final result =
        await _authService.signUpWithEmailAndPassword(email, password, name);
    _lastMessage = result.message;
    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<AuthActionResult> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    final result = await _authService.signInWithGoogle();
    _lastMessage = result.message;
    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<AuthActionResult> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    notifyListeners();
    final result = await _authService.sendPasswordResetEmail(email);
    _lastMessage = result.message;
    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<void> signOut() async {
    _appUser = null;
    await _authService.signOut();
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
