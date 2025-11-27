import 'dart:async';

import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

enum AuthStatus { loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _init();
  }

  final AuthService _authService = AuthService();
  AuthStatus _status = AuthStatus.loading;
  AppUser? _currentUser;
  String? _error;

  AuthStatus get status => _status;
  AppUser? get currentUser => _currentUser;
  String? get error => _error;

  Future<void> _init() async {
    final isAuth = await _authService.isAuthenticated();
    if (isAuth) {
      try {
        final user = await _authService.getProfile();
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } catch (_) {
        _status = AuthStatus.unauthenticated;
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String identity, String password) async {
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      final user = await _authService.login(identity, password);
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
    required String role,
    required String zone,
  }) async {
    _status = AuthStatus.loading;
    notifyListeners();
    try {
      final user = await _authService.register(
        fullName: fullName,
        email: email,
        username: username,
        password: password,
        role: role,
        zone: zone,
      );
      _currentUser = user;
      _status = AuthStatus.authenticated;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _error = null;
    notifyListeners();
  }
}
