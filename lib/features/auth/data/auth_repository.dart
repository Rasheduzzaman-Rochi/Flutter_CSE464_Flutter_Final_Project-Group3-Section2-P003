class AuthRepository {
  String? _registeredName;
  String? _registeredPhone;
  String? _registeredEmail;
  String? _registeredPassword;
  bool _otpVerified = false;

  String? get registeredName => _registeredName;
  String? get registeredPhone => _registeredPhone;
  String? get registeredEmail => _registeredEmail;
  bool get isRegistered =>
      _registeredEmail != null && _registeredPassword != null;
  bool get isOtpVerified => _otpVerified;

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

  Future<String?> signInWithGoogle() async => null;

  Future<String?> signInWithFacebook() async => null;

  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
}
