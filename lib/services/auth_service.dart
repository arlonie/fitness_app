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

  // Send email verification
  Future<void> sendEmailVerification(User user) async {
    try {
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        logger.i("Verification email sent to ${user.email}");
      }
    } catch (e) {
      logger.e("Error sending verification email: $e");
      rethrow;
    }
  }

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
        await sendEmailVerification(firebaseUser);

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

        // Sign out immediately to require verification before access
        await _auth.signOut();

        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      logger.e("SignUp Error: $e");
      rethrow;
    } catch (e) {
      logger.e("Unexpected SignUp Error: $e");
      rethrow;
    }
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
          await sendEmailVerification(firebaseUser);
          throw FirebaseAuthException(
            code: 'email-not-verified',
            message: '$email is not verified. Please check your inbox or spam.',
          );
        }

        // Get user data from Realtime Database
        DatabaseEvent event = await _db
            .child('users/${firebaseUser.uid}')
            .once();
        final data = event.snapshot.value;

        if (data == null) {
          throw Exception('User data not found in database.');
        }

        return UserModel.fromJson(Map<String, dynamic>.from(data as Map));
      }
    } on FirebaseAuthException catch (e) {
      logger.i("SignIn Error: $e");
      rethrow;
    } catch (e) {
      logger.i("SignIn Error: $e");
      rethrow;
    }
    return null;
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      logger.i("Reset Password Error: $e");
      rethrow;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
