import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../data/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
    : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _userEmail;
  String _lastOtpCode = '';

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get isRegistered => _repository.isRegistered;
  String? get userName => _repository.registeredName;
  String? get userPhone => _repository.registeredPhone;
  String? get userEmail => _userEmail ?? _repository.registeredEmail;
  String get lastOtpCode => _lastOtpCode;

  String get initialAuthRoute {
    if (!_repository.isRegistered) {
      return AppRoutes.signup;
    }

    if (!_repository.isOtpVerified) {
      return AppRoutes.otp;
    }

    return AppRoutes.login;
  }

  Future<String?> signUp(
    String name,
    String phone,
    String email,
    String password,
  ) async {
    _setLoading(true);
    final error = await _repository.signUpWithEmail(
      name,
      phone,
      email,
      password,
    );

    if (error == null) {
      await _repository.sendOTP(email, (code) => _lastOtpCode = code);
      _userEmail = email.trim().toLowerCase();
    }

    _setLoading(false);
    return error;
  }

  Future<String?> verifyOtp(String otp) async {
    _setLoading(true);
    final error = await _repository.verifyOTP(_lastOtpCode, otp);
    _setLoading(false);
    return error;
  }

  Future<String?> login(String email, String password) async {
    _setLoading(true);
    final error = await _repository.loginWithEmail(email, password);

    if (error == null) {
      _isLoggedIn = true;
      _userEmail = email.trim().toLowerCase();
      notifyListeners();
    }

    _setLoading(false);
    return error;
  }

  Future<void> logout() async {
    _setLoading(true);
    await _repository.signOut();
    _isLoggedIn = false;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
