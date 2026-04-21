import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: ['email']);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  String? _registeredName;
  String? _registeredPhone;
  String? _registeredEmail;

  User? get currentUser => _auth.currentUser;

  bool get isRegistered => _auth.currentUser != null;
  bool get isOtpVerified => true;
  bool get isGoogleAccount =>
      _auth.currentUser?.providerData.any(
        (provider) => provider.providerId == 'google.com',
      ) ??
      false;

  String? get registeredName =>
      _registeredName ?? _auth.currentUser?.displayName;
  String? get registeredPhone => _registeredPhone;
  String? get registeredEmail => _registeredEmail ?? _auth.currentUser?.email;

  Future<void> loadCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      _registeredName = null;
      _registeredPhone = null;
      _registeredEmail = null;
      return;
    }

    _registeredName = user.displayName;
    _registeredEmail = user.email;

    final snapshot = await _firestore.collection('users').doc(user.uid).get();
    final data = snapshot.data();
    _registeredName = data?['name'] as String? ?? _registeredName;
    _registeredPhone = data?['phone'] as String?;
    _registeredEmail = data?['email'] as String? ?? _registeredEmail;
  }

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

      final user = credential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name.trim(),
          'phone': phone.trim(),
          'email': email.trim().toLowerCase(),
          'provider': 'password',
          'createdAt': FieldValue.serverTimestamp(),
        });

        _registeredName = name.trim();
        _registeredPhone = phone.trim();
        _registeredEmail = email.trim().toLowerCase();
      }

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

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName ?? 'Google User',
          'phone': user.phoneNumber ?? '',
          'email': user.email ?? account.email,
          'provider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        _registeredName = user.displayName ?? 'Google User';
        _registeredPhone = user.phoneNumber ?? '';
        _registeredEmail = user.email ?? account.email;
      }
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
    _registeredName = null;
    _registeredPhone = null;
    _registeredEmail = null;
  }
}
