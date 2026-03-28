import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AppAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AppAuthProvider() {
    _authService.user.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    await _authService.signInWithGoogle();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    await _authService.loginWithEmail(email, password);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> registerWithEmail(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();
    await _authService.registerWithEmail(email, password, name);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
