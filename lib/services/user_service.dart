import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:logger/logger.dart';

class UserService {
  final logger = Logger();
  final DatabaseReference _db = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        "https://fitness-app-18217-default-rtdb.asia-southeast1.firebasedatabase.app/",
  ).ref();

  // Update user profile
  Future<void> updateUserProfile(
    String uid,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _db.child('users/$uid').update(updates);
      logger.i("User profile updated for UID: $uid");
    } catch (e) {
      logger.e("Error updating user profile: $e");
      rethrow;
    }
  }
}
