import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //sign up with email and password + send verification
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // return userCred.user;
      User? user = userCred.user;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        if (kDebugMode) {
          print("Verification email sent to ${user.email}");
        }
      }

      return user;
    } catch (e) {
      if (kDebugMode) {
        print("Sign up Error: $e");
      }
      return null;
    }
  }

  //login only if email is verified
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCred.user;

      if (user != null && user.emailVerified) {
        return user;
      } else {
        if (kDebugMode) {
          print("Email not verified for ${user?.email}");
        }
        await _auth.signOut();
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Sign in Error:$e");
      }
      return null;
    }
  }

  //sign out
  Future<void> signOut() async {
    await _auth.signOut();
    if (kDebugMode) {
      print("User signed out");
    }
  }
}
