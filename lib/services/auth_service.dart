import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final logger = Logger();
  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        "https://fitness-app-18217-default-rtdb.asia-southeast1.firebasedatabase.app/",
  ).ref();

  // Register new user
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = result.user;

      if (firebaseUser != null) {
        // Send email verification
        if (!firebaseUser.emailVerified) {
          await firebaseUser.sendEmailVerification();
          logger.i("Verification email sent to $email");
          // print("Verification email sent to $email");
        }

        // Create UserModel
        UserModel user = UserModel(
          id: firebaseUser.uid,
          email: email,
          firstname: firstname,
          lastname: lastname,
          height: null,
          weight: null,
          goal: null,
        );

        // Save to Realtime Database
        await _db.child('users/${firebaseUser.uid}').set(user.toJson());

        return user;
      }
    } catch (e) {
      logger.i("SignUp Error: $e");
      // print("SignUp Error: $e");
    }
    return null;
  }

  // Login user
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = result.user;

      if (firebaseUser != null) {
        // Check email verification
        if (!firebaseUser.emailVerified) {
          // Send verification email again if needed
          await firebaseUser.sendEmailVerification();
          logger.i("Verification email sent to $email");
          // print("Verification email sent to $email");

          // Throw an error to stop login
          throw FirebaseAuthException(
            code: 'email-not-verified',
            message: '$email is not verified. Please check your inbox or spam.',
          );
        }

        // Get user data from Realtime Database
        DatabaseEvent event = await _db
            .child('users/${firebaseUser.uid}')
            .once();
        final data = event.snapshot.value as Map<dynamic, dynamic>;

        return UserModel.fromJson(Map<String, dynamic>.from(data));
      }
    } on FirebaseAuthException catch (e) {
      logger.i("SignIn Error: $e");
      // print("SignIn Error: $e");
      rethrow; // Pass error to UI to show snackbar or dialog
    } catch (e) {
      logger.i("SignIn Error: $e");
      // print("SignIn Error: $e");
    }
    return null;
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      logger.i("Reset Password Error: $e");
      // print("Reset Password Error: $e");
      rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
