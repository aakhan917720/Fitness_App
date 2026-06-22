import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get userId => _auth.currentUser?.uid;

  // Save workout
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
    if (userId == null) {
      print('ERROR: userId is null!');
      throw Exception('User not logged in');
    }

    print('Current user ID: ${FirebaseAuth.instance.currentUser?.uid}');
    print('Saving workout for user: $userId');

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

    try {
      DocumentReference docRef = await _firestore.collection('workouts').add(workoutData);
      print('Workout saved with ID: ${docRef.id}');

      await _updateUserStats(caloriesBurned, duration);
      print('User stats updated');
    } catch (e) {
      print('Error saving workout: $e');
      throw e;
    }
  }

  // Update user stats
  Future<void> _updateUserStats(int calories, int minutes) async {
    if (userId == null) return;

    final userRef = _firestore.collection('users').doc(userId);

    try {
      DocumentSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        int currentWorkouts = _getIntValue(data['totalWorkouts']);
        int currentCalories = _getIntValue(data['totalCalories']);
        int currentMinutes = _getIntValue(data['totalMinutes']);

        await userRef.update({
          'totalWorkouts': currentWorkouts + 1,
          'totalCalories': currentCalories + calories,
          'totalMinutes': currentMinutes + minutes,
          'lastWorkoutAt': FieldValue.serverTimestamp(),
        });
      } else {
        await userRef.set({
          'totalWorkouts': 1,
          'totalCalories': calories,
          'totalMinutes': minutes,
          'lastWorkoutAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error updating user stats: $e');
      throw e;
    }
  }

  // Helper to safely get int values
  int _getIntValue(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return 0;
  }

  // Get today's workouts - NO orderBy to avoid index
  Stream<QuerySnapshot> getTodayWorkouts() {
    if (userId == null) {
      print('ERROR: userId is null in getTodayWorkouts');
      return Stream.empty();
    }

    print('Getting today workouts for user: $userId');

    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);

    // Simple query - only where, no orderBy
    return _firestore
        .collection('workouts')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .snapshots();
  }

  // Get all workouts - NO orderBy to avoid index
  Stream<QuerySnapshot> getAllWorkouts() {
    if (userId == null) {
      print('ERROR: userId is null in getAllWorkouts');
      return Stream.empty();
    }

    print('Getting all workouts for user: $userId');

    // Simple query - only where, no orderBy
    return _firestore
        .collection('workouts')
        .where('userId', isEqualTo: userId)
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
}