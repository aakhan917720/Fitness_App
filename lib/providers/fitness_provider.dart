import 'package:flutter/cupertino.dart';
import '../modals/exercise.dart';

class UserStats {
  double weight;
  double height;
  double bmi;
  int totalWorkouts;
  int totalMinutes;
  double totalCalories;
  int age;
  String gender;

  UserStats({
    this.weight = 70.0,
    this.height = 170.0,
    this.bmi = 24.2,
    this.totalWorkouts = 0,
    this.totalMinutes = 0,
    this.totalCalories = 0.0,
    this.age = 0,
    this.gender = '',
  });
}

class WorkoutSession {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final DateTime date;
  final int durationMinutes;
  final int caloriesBurned;

  WorkoutSession({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.date,
    required this.durationMinutes,
    required this.caloriesBurned,
  });
}

// --- Main Provider ---
class FitnessProvider extends ChangeNotifier {
  final UserStats _userStats = UserStats();
  final List<WorkoutSession> _sessions = [];
  List<Exercise> _exercises = [];
  bool _isWorkoutActive = false;
  int _currentWorkoutSeconds = 0;
  Exercise? _currentExercise;

  UserStats get userStats => _userStats;
  List<WorkoutSession> get sessions => _sessions;
  List<Exercise> get exercises => _exercises;
  bool get isWorkoutActive => _isWorkoutActive;
  int get currentWorkoutSeconds => _currentWorkoutSeconds;
  Exercise? get currentExercise => _currentExercise;

  FitnessProvider() {
    _loadExercises();
  }

  void _loadExercises() {
    _exercises = [
      Exercise(
        id: '1',
        name: 'Jumping Jacks',
        category: 'Cardio',
        description: 'Full body cardio exercise that increases heart rate',
        duration: 60,
        calories: 10,
        difficulty: 'Beginner',
        imagePath: '',
        modifyPath: '',
        imageUrl: 'https://images.unsplash.com/photo-1599058945522-28d584b6f0ff?w=400&h=300&fit=crop',
        steps: ['Stand straight', 'Jump with legs apart', 'Raise arms', 'Return to start'],
      ),
      Exercise(
        id: '2',
        name: 'Push-ups',
        category: 'Strength',
        description: 'Classic upper body strength exercise',
        duration: 45,
        calories: 8,
        difficulty: 'Intermediate',
        imagePath: '',
        modifyPath: '',
        imageUrl: 'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?w=400&h=300&fit=crop',
        steps: ['Get in plank position', 'Lower body', 'Push back up', 'Repeat'],
      ),
      Exercise(
        id: '3',
        name: 'Squats',
        category: 'Strength',
        description: 'Lower body exercise for legs and glutes',
        duration: 60,
        calories: 12,
        difficulty: 'Beginner',
        imagePath: '',
        modifyPath: '',
        imageUrl: 'https://images.unsplash.com/photo-1574680178050-55c6a6a96e0a?w=400&h=300&fit=crop',
        steps: ['Stand with feet apart', 'Lower hips back', 'Keep back straight', 'Stand up'],
      ),
      Exercise(
        id: '4',
        name: 'Plank',
        category: 'Core',
        description: 'Core strengthening exercise',
        duration: 60,
        calories: 5,
        difficulty: 'Beginner',
        imagePath: '',
        modifyPath: '',
        imageUrl: 'https://images.unsplash.com/photo-1566241440091-ec10de8db2e1?w=400&h=300&fit=crop',
        steps: ['Get in push-up position', 'Hold on forearms', 'Keep body straight', 'Hold position'],
      ),
      Exercise(
        id: '5',
        name: 'Burpees',
        category: 'HIIT',
        description: 'High intensity full body exercise',
        duration: 45,
        calories: 15,
        difficulty: 'Advanced',
        imagePath: '',
        modifyPath: '',
        imageUrl: 'https://images.unsplash.com/photo-1434596922112-19c563067271?w=400&h=300&fit=crop',
        steps: ['Start standing', 'Drop to squat', 'Jump back to plank', 'Jump forward and up'],
      ),
      Exercise(
        id: '6',
        name: 'Mountain Climbers',
        category: 'Cardio',
        description: 'Dynamic cardio and core exercise',
        duration: 45,
        calories: 12,
        difficulty: 'Intermediate',
        imagePath: '',
        modifyPath: '',
        imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400&h=300&fit=crop',
        steps: ['Get in plank position', 'Bring knee to chest', 'Switch legs quickly', 'Keep core tight'],
      ),
      Exercise(
        id: '7',
        name: 'Lunges',
        category: 'Strength',
        description: 'Leg strengthening exercise',
        duration: 60,
        calories: 10,
        difficulty: 'Beginner',
        imagePath: '',
        modifyPath: '',
        imageUrl: 'https://images.unsplash.com/photo-1534258936925-c48947387e3b?w=400&h=300&fit=crop',
        steps: ['Step forward', 'Lower back knee', 'Keep front knee 90 degrees', 'Push back up'],
      ),
      Exercise(
        id: '8',
        name: 'High Knees',
        category: 'Cardio',
        description: 'Running in place with high knees',
        duration: 45,
        calories: 14,
        difficulty: 'Beginner',
        imagePath: '',
        modifyPath: '',
        imageUrl: 'https://images.unsplash.com/photo-1601422407692-ec4eeec1d9b3?w=400&h=300&fit=crop',
        steps: ['Stand tall', 'Run in place', 'Lift knees high', 'Pump arms'],
      ),
    ];
    notifyListeners();
  }

  // Get exercises by category
  List<Exercise> getExercisesByCategory(String category) {
    return _exercises.where((exercise) => exercise.category.toLowerCase() == category.toLowerCase()).toList();
  }

  // Workout control methods
  void startWorkout(Exercise exercise) {
    _isWorkoutActive = true;
    _currentExercise = exercise;
    _currentWorkoutSeconds = 0;
    notifyListeners();
  }

  void incrementWorkoutTime() {
    if (_isWorkoutActive) {
      _currentWorkoutSeconds++;
      notifyListeners();
    }
  }

  void cancelWorkout() {
    _isWorkoutActive = false;
    _currentExercise = null;
    _currentWorkoutSeconds = 0;
    notifyListeners();
  }

  void completeWorkout() {
    if (_isWorkoutActive && _currentExercise != null) {
      int durationMins = (_currentWorkoutSeconds / 60).ceil();
      int calories = _currentExercise!.calories;

      _sessions.add(
        WorkoutSession(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          exerciseId: _currentExercise!.id,
          exerciseName: _currentExercise!.name,
          date: DateTime.now(),
          durationMinutes: durationMins,
          caloriesBurned: calories,
        ),
      );

      _userStats.totalWorkouts += 1;
      _userStats.totalMinutes += durationMins;
      _userStats.totalCalories += calories;
    }
    cancelWorkout();
  }

  // Today's Dashboard stats calculation
  int getTodayCalories() {
    DateTime now = DateTime.now();
    return _sessions
        .where((s) => s.date.year == now.year && s.date.month == now.month && s.date.day == now.day)
        .fold(0, (sum, item) => sum + item.caloriesBurned);
  }

  int getTodayMinutes() {
    DateTime now = DateTime.now();
    return _sessions
        .where((s) => s.date.year == now.year && s.date.month == now.month && s.date.day == now.day)
        .fold(0, (sum, item) => sum + item.durationMinutes);
  }

  int getTodayWorkouts() {
    DateTime now = DateTime.now();
    return _sessions
        .where((s) => s.date.year == now.year && s.date.month == now.month && s.date.day == now.day)
        .length;
  }

  void updateUserStats({double? weight, double? height, int? age, String? gender}) {
    if (weight != null) _userStats.weight = weight;
    if (height != null) _userStats.height = height;
    if (age != null) _userStats.age = age;
    if (gender != null) _userStats.gender = gender;

    // BMI calculation
    double heightInMeters = _userStats.height / 100;
    if (heightInMeters > 0) {
      _userStats.bmi = _userStats.weight / (heightInMeters * heightInMeters);
    }

    notifyListeners();
  }
}