import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
enum AuthStatus {
  NOT_DETERMINED, //e.g. firestore unreacheable
  NOT_LOGGED_IN,
  LOGGED_IN,
}

class Authenticator  {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String userId = "";


  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    userId=user.uid;
    return user.uid;
  }

  Future<String> signUp(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    userId = user.uid;
    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    authStatus= AuthStatus.NOT_LOGGED_IN;
    userId="";
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

}
