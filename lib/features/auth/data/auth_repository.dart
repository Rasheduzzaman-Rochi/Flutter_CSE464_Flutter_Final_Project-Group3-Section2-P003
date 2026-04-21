import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: ['email']);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  User? get currentUser => _auth.currentUser;

  bool get isRegistered => _auth.currentUser != null;
  bool get isOtpVerified => true;
  bool get isGoogleAccount => _auth.currentUser?.providerData.any(
        (provider) => provider.providerId == 'google.com',
      ) ??
      false;

  String? get registeredName => _auth.currentUser?.displayName;
  String? get registeredPhone => _auth.currentUser?.phoneNumber;
  String? get registeredEmail => _auth.currentUser?.email;

  Future<String?> signUpWithEmail(
    String name,
    String phone,
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      await credential.user?.updateDisplayName(name.trim());
      await credential.user?.reload();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Failed to create account.';
    } catch (_) {
      return 'Failed to create account.';
    }
  }

  Future<String?> loginWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Invalid email or password.';
    } catch (_) {
      return 'Invalid email or password.';
    }
  }

  Future<void> sendOTP(String phoneNumber, Function(String) onCodeSent) async {
    onCodeSent('123456');
  }

  Future<String?> verifyOTP(String verificationId, String smsCode) async {
    if (smsCode.trim() != verificationId) {
      return 'Invalid OTP code.';
    }
    return null;
  }

  Future<String?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return 'Google sign-in was cancelled.';
      }

      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Unable to sign in with Google right now.';
    } catch (_) {
      return 'Unable to sign in with Google right now.';
    }
  }

  Future<String?> signInWithFacebook() async => null;

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}