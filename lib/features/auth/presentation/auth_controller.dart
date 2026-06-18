import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fire = FirebaseFirestore.instance;

  final user = Rxn<User>();
  final loading = false.obs;
  final error = RxnString();
  final displayName = RxnString();

  @override
  void onInit() {
    super.onInit();
    user.value = _auth.currentUser;
    _auth.authStateChanges().listen((u) {
      user.value = u;
      if (u != null) {
        _loadProfile(u.uid);
      } else {
        displayName.value = null;
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    loading.value = true;
    error.value = null;
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      user.value = cred.user;
      if (cred.user != null) await _loadProfile(cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      error.value = _mapAuthError(e);
    } finally {
      loading.value = false;
    }
  }

  Future<void> signUp(String name, String email, String password) async {
    loading.value = true;
    error.value = null;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final u = cred.user;
      if (u != null) {
        await _fire.collection('users').doc(u.uid).set({'name': name, 'email': email});
        displayName.value = name;
      }
      user.value = u;
    } on FirebaseAuthException catch (e) {
      error.value = _mapAuthError(e);
    } finally {
      loading.value = false;
    }
  }

  Future<void> _loadProfile(String uid) async {
    try {
      final doc = await _fire.collection('users').doc(uid).get();
      if (doc.exists) {
        displayName.value = doc.data()?['name'] as String?;
      }
    } catch (_) {
      displayName.value = null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      user.value = null;
    } catch (e) {
      error.value = 'Could not sign out. Please try again.';
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for that email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'The password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Check Firebase settings.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again later.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      default:
        return e.message ?? 'Authentication error. Please try again.';
    }
  }
}
