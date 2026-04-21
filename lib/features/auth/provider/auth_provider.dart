import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../data/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository() {
    _syncUser();
  }

  final AuthRepository _repository;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String? _userEmail;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get isRegistered => _repository.isRegistered;
  String? get userName => _repository.registeredName;
  String? get userPhone => _repository.registeredPhone;
  String? get userEmail => _userEmail ?? _repository.registeredEmail;
  String get lastOtpCode => '123456';
  bool get isGoogleAccount => _repository.isGoogleAccount;

  String get initialAuthRoute {
    return _firebaseAuth.currentUser == null
        ? AppRoutes.login
        : AppRoutes.home;
  }

  void _syncUser() {
    final user = _firebaseAuth.currentUser;
    _isLoggedIn = user != null;
    _userEmail = user?.email;
  }

  Future<String?> signUp(
    String name,
    String phone,
    String email,
    String password,
  ) async {
    _setLoading(true);
    final error = await _repository.signUpWithEmail(name, phone, email, password);

    if (error == null) {
      _syncUser();
    }

    _setLoading(false);
    return error;
  }

  Future<String?> verifyOtp(String otp) async {
    return null;
  }

  Future<String?> login(String email, String password) async {
    _setLoading(true);
    final error = await _repository.loginWithEmail(email, password);

    if (error == null) {
      _syncUser();
      notifyListeners();
    }

    _setLoading(false);
    return error;
  }

  Future<String?> signInWithGoogle() async {
    _setLoading(true);
    final error = await _repository.signInWithGoogle();

    if (error == null) {
      _syncUser();
      notifyListeners();
    }

    _setLoading(false);
    return error;
  }

  Future<void> logout() async {
    _setLoading(true);
    await _repository.signOut();
    _isLoggedIn = false;
    _userEmail = null;
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}