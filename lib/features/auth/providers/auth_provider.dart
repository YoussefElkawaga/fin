import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fin/core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  AuthProvider() {
    _init();
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    await _authService.signIn(email: email, password: password);
  }

  Future<void> signUp(String email, String password, String name) async {
    await _authService.signUp(
      email: email,
      password: password,
      name: name,
    );
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
} 