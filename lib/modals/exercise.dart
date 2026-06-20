class Exercise {
  final String id;
  final String name;
  final String category;
  final String description;
  final int duration;
  final int calories;
  final String difficulty;
  final String imagePath;
  final List<String> steps;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.duration,
    required this.calories,
    required this.difficulty,
    this.imagePath = '',
    required this.steps,
  });
}

class WorkoutSession {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final DateTime date;
  final int duration;
  final int caloriesBurned;

  WorkoutSession({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.date,
    required this.duration,
    required this.caloriesBurned,
  });
}

class UserStats {
  double weight;
  double height;
  int age;
  String gender;
  double bmi;
  int totalWorkouts;
  int totalCalories;
  int totalMinutes;

  UserStats({
    this.weight = 70.0,
    this.height = 170.0,
    this.age = 25,
    this.gender = 'Male',
    this.bmi = 24.2,
    this.totalWorkouts = 0,
    this.totalCalories = 0,
    this.totalMinutes = 0,
  });
}