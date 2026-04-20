import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  AuthRepository({GoogleSignIn? googleSignIn})
    : _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: ['email']);

  final GoogleSignIn _googleSignIn;

  String? _registeredName;
  String? _registeredPhone;
  String? _registeredEmail;
  String? _registeredPassword;
  bool _otpVerified = false;
  bool _isGoogleAccount = false;

  String? get registeredName => _registeredName;
  String? get registeredPhone => _registeredPhone;
  String? get registeredEmail => _registeredEmail;
  bool get isRegistered =>
      _registeredEmail != null &&
      (_registeredPassword != null || _isGoogleAccount);
  bool get isOtpVerified => _otpVerified;
  bool get isGoogleAccount => _isGoogleAccount;

  Future<String?> signUpWithEmail(
    String name,
    String phone,
    String email,
    String password,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));

    if (name.trim().isEmpty) {
      return 'Please provide your name.';
    }

    if (phone.trim().length < 8) {
      return 'Please provide a valid mobile number.';
    }

    if (email.trim().isEmpty || password.length < 6) {
      return 'Please provide valid email and password (min 6 characters).';
    }

    _registeredName = name.trim();
    _registeredPhone = phone.trim();
    _registeredEmail = email.trim().toLowerCase();
    _registeredPassword = password;
    _otpVerified = false;
    _isGoogleAccount = false;
    return null;
  }

  Future<String?> loginWithEmail(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (!isRegistered) {
      return 'No account found. Please sign up first.';
    }

    if (!_otpVerified) {
      return 'Please verify your account with OTP first.';
    }

    if (_registeredEmail != email.trim().toLowerCase() ||
        _registeredPassword != password) {
      return 'Invalid email or password.';
    }

    return null;
  }

  Future<void> sendOTP(String phoneNumber, Function(String) onCodeSent) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    onCodeSent('123456');
  }

  Future<String?> verifyOTP(String verificationId, String smsCode) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (smsCode.trim() != verificationId) {
      return 'Invalid OTP code.';
    }

    _otpVerified = true;
    return null;
  }

  Future<String?> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return 'Google sign-in was cancelled.';
      }

      _registeredName = account.displayName?.trim().isNotEmpty == true
          ? account.displayName!.trim()
          : 'Google User';
      _registeredPhone = '';
      _registeredEmail = account.email.trim().toLowerCase();
      _registeredPassword = '';
      _otpVerified = true;
      _isGoogleAccount = true;
      return null;
    } catch (_) {
      return 'Unable to sign in with Google right now.';
    }
  }

  Future<String?> signInWithFacebook() async => null;

  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await _googleSignIn.signOut();
    _registeredName = null;
    _registeredPhone = null;
    _registeredEmail = null;
    _registeredPassword = null;
    _otpVerified = false;
    _isGoogleAccount = false;
  }
}
