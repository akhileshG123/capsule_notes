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
    // Synchronously set user from cached Firebase state so that
    // isAuthenticated is immediately correct on app restart.
    _user = FirebaseAuth.instance.currentUser;

    // Also listen for future auth changes (login / logout / token refresh).
    _authService.user.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    await _authService.signInWithGoogle();
    _user = FirebaseAuth.instance.currentUser;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loginWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    await _authService.loginWithEmail(email, password);
    _user = FirebaseAuth.instance.currentUser;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> registerWithEmail(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();
    await _authService.registerWithEmail(email, password, name);
    _user = FirebaseAuth.instance.currentUser;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
