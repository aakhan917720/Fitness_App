import 'package:flutter/material.dart';

import '../modals/exercise.dart';

class FitnessProvider extends ChangeNotifier {
  UserStats _userStats = UserStats();
  List<WorkoutSession> _sessions = [];
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
        imagePath: 'assets/images/jumping_jacks.jpg',
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
        imagePath: 'assets/images/pushups.jpg',
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
        imagePath: 'assets/images/squats.jpg',
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
        imagePath: 'assets/images/plank.jpg',
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
        imagePath: 'assets/images/burpees.jpg',
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
        imagePath: 'assets/images/mountain_climbers.jpg',
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
        imagePath: 'assets/images/lunges.jpg',
        steps: ['Step forward', 'Lower back knee', 'Keep front knee 90°', 'Push back up'],
      ),
      Exercise(
        id: '8',
        name: 'High Knees',
        category: 'Cardio',
        description: 'Running in place with high knees',
        duration: 45,
        calories: 14,
        difficulty: 'Beginner',
        imagePath: 'assets/images/high_knees.jpg',
        steps: ['Stand tall', 'Run in place', 'Lift knees high', 'Pump arms'],
      ),
    ];
    notifyListeners();
  }

  void updateUserStats({double? weight, double? height, int? age, String? gender}) {
    if (weight != null) _userStats.weight = weight;
    if (height != null) _userStats.height = height;
    if (age != null) _userStats.age = age;
    if (gender != null) _userStats.gender = gender;
    _calculateBMI();
    notifyListeners();
  }

  void _calculateBMI() {
    double heightInMeters = _userStats.height / 100;
    _userStats.bmi = _userStats.weight / (heightInMeters * heightInMeters);
    notifyListeners();
  }

  void startWorkout(Exercise exercise) {
    _currentExercise = exercise;
    _isWorkoutActive = true;
    _currentWorkoutSeconds = 0;
    notifyListeners();
  }

  void incrementWorkoutTime() {
    _currentWorkoutSeconds++;
    notifyListeners();
  }

  void completeWorkout() {
    if (_currentExercise != null) {
      final session = WorkoutSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        exerciseId: _currentExercise!.id,
        exerciseName: _currentExercise!.name,
        date: DateTime.now(),
        duration: _currentWorkoutSeconds,
        caloriesBurned: (_currentExercise!.calories * _currentWorkoutSeconds / _currentExercise!.duration).round(),
      );
      _sessions.add(session);
      _userStats.totalWorkouts++;
      _userStats.totalCalories += session.caloriesBurned;
      _userStats.totalMinutes += (_currentWorkoutSeconds / 60).round();
    }
    _isWorkoutActive = false;
    _currentWorkoutSeconds = 0;
    _currentExercise = null;
    notifyListeners();
  }

  void cancelWorkout() {
    _isWorkoutActive = false;
    _currentWorkoutSeconds = 0;
    _currentExercise = null;
    notifyListeners();
  }

  List<Exercise> getExercisesByCategory(String category) {
    if (category == 'All') return _exercises;
    return _exercises.where((e) => e.category == category).toList();
  }

  int getTodayCalories() {
    final today = DateTime.now();
    return _sessions
        .where((s) => s.date.year == today.year && s.date.month == today.month && s.date.day == today.day)
        .fold(0, (sum, s) => sum + s.caloriesBurned);
  }

  int getTodayMinutes() {
    final today = DateTime.now();
    return _sessions
        .where((s) => s.date.year == today.year && s.date.month == today.month && s.date.day == today.day)
        .fold(0, (sum, s) => sum + s.duration) ~/ 60;
  }

  int getTodayWorkouts() {
    final today = DateTime.now();
    return _sessions
        .where((s) => s.date.year == today.year && s.date.month == today.month && s.date.day == today.day)
        .length;
  }

  List<WorkoutSession> getSessionsForDate(DateTime date) {
    return _sessions
        .where((s) => s.date.year == date.year && s.date.month == date.month && s.date.day == date.day)
        .toList();
  }
}