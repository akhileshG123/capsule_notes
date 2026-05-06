import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _googleInitialized = false;

  Stream<User?> get user => _auth.authStateChanges();

  Future<void> _ensureGoogleInitialized() async {
    if (!_googleInitialized) {
      await _googleSignIn.initialize();
      _googleInitialized = true;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _ensureGoogleInitialized();

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      await _createUserDocumentIfNeeded(userCredential.user!);
      return userCredential;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return null;
    }
  }

  Future<UserCredential?> registerWithEmail(String email, String password, String displayName) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await userCredential.user!.updateDisplayName(displayName);

      UserModel newUser = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
      return userCredential;
    } catch (e) {
      debugPrint('Register error: $e');
      return null;
    }
  }

  Future<UserCredential?> loginWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint('Login error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _ensureGoogleInitialized();
      await _googleSignIn.signOut();
    } catch (_) {
      // Google sign out may fail if never initialized; ignore.
    }
    await _auth.signOut();
  }

  Future<void> _createUserDocumentIfNeeded(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();
    
    if (!doc.exists) {
      UserModel newUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        createdAt: DateTime.now(),
      );
      await docRef.set(newUser.toMap());
    }
  }
}
