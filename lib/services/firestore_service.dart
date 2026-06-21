import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get userId => _auth.currentUser?.uid;

  // Save workout data
  Future<void> saveWorkout({
    required String exerciseId,
    required String exerciseName,
    required String category,
    required int duration,
    required int caloriesBurned,
    required double? latitude,
    required double? longitude,
    required String? locationName,
  }) async {
    if (userId == null) return;

    final workoutData = {
      'userId': userId,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'category': category,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'completedAt': FieldValue.serverTimestamp(),
      'date': Timestamp.now(),
    };

    // Add to workouts collection
    await _firestore.collection('workouts').add(workoutData);

    // Update user stats
    await _updateUserStats(caloriesBurned, duration);
  }

  // Update user total stats
  Future<void> _updateUserStats(int calories, int minutes) async {
    if (userId == null) return;

    final userRef = _firestore.collection('users').doc(userId);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        int currentWorkouts = data['totalWorkouts'] ?? 0;
        int currentCalories = data['totalCalories'] ?? 0;
        int currentMinutes = data['totalMinutes'] ?? 0;

        transaction.update(userRef, {
          'totalWorkouts': currentWorkouts + 1,
          'totalCalories': currentCalories + calories,
          'totalMinutes': currentMinutes + minutes,
        });
      }
    });
  }

  // Get today's workouts
  Stream<QuerySnapshot> getTodayWorkouts() {
    if (userId == null) return Stream.empty();

    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    return _firestore
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .orderBy('completedAt', descending: true)
        .snapshots();
  }

  // Get all workouts
  Stream<QuerySnapshot> getAllWorkouts() {
    if (userId == null) return Stream.empty();

    return _firestore
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .orderBy('completedAt', descending: true)
        .snapshots();
  }

  // Get user stats
  Future<Map<String, dynamic>?> getUserStats() async {
    if (userId == null) return null;

    DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return null;
  }

  // Save user profile
  Future<void> saveUserProfile({
    required String name,
    required int age,
    required String gender,
    required double weight,
    required double height,
  }) async {
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).update({
      'name': name,
      'age': age,
      'gender': gender,
      'weight': weight,
      'height': height,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}