import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

enum AuthStatus {
  NOT_DETERMINED, //e.g. firestore unreacheable
  NOT_LOGGED_IN,
  LOGGED_IN, //
  SIGNED_UP, //user has signed up & verification mail is sent
}

class Authenticator {
  FirebaseAuth _firebaseAuth;
  AuthStatus _authStatus;
  String _userId;

  Authenticator() {
    _authStatus = AuthStatus.NOT_DETERMINED;
    _userId = "";
    _firebaseAuth = FirebaseAuth.instance;
  }

  AuthStatus getStatus() {
    return _authStatus;
  }

  Future<AuthStatus> signIn(String email, String password) async {
    try {
      FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      bool emailVerified = await _isEmailVerified();
      _userId = user.uid;

      if (emailVerified) {
        return _authStatus = AuthStatus.LOGGED_IN;
      } else {
        return _authStatus = AuthStatus.SIGNED_UP;
      }
    } catch (error) {
      return _authStatus = AuthStatus.NOT_DETERMINED;
    }
  }

  Future<AuthStatus> signUp(String email, String password) async {
    try {
      FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      return _authStatus = AuthStatus.SIGNED_UP;
    } catch (signupError) {
      return _authStatus = AuthStatus.NOT_DETERMINED;
    }
  }

  Future<AuthStatus> signOut() async {
    try {
      _userId = "";
      _firebaseAuth.signOut();
      return _authStatus = AuthStatus.NOT_LOGGED_IN;
    } catch (error) {
      return _authStatus = AuthStatus.NOT_DETERMINED;
    }
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    if (user != null) {
      user.sendEmailVerification();
    }
  }

  Future<bool> _isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    if (user == null) {
      return false;
    } else {
      return user.isEmailVerified;
    }
  }

  Future<AuthStatus> checkAuthStatus() async {
    try {
      FirebaseUser user = await _firebaseAuth.currentUser();

      if (user != null) {
        bool mailVerified = await _isEmailVerified();
        if (mailVerified) {
          return _authStatus = AuthStatus.LOGGED_IN;
        } else {
          return _authStatus = AuthStatus.SIGNED_UP;
        }
      } else {
        return _authStatus = AuthStatus.NOT_LOGGED_IN;
      }
    } catch (e) {
      return _authStatus = AuthStatus.NOT_DETERMINED;
    }
  }

  String getUserId() {
    return _userId;
  }
}
