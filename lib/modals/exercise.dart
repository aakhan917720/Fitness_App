class Exercise {
  final String id;
  final String name;
  final String category;
  final String description;
  final int duration;
  final int calories;
  final String difficulty;
  final String imagePath;  // Local asset path
  final String imageUrl;   // Network URL  ← YEH ADD KARA
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
    this.imageUrl = '',     // ← YEH ADD KARA
    required this.steps, required String modifyPath,
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
  int age;
  String gender;
  int totalWorkouts;
  double totalMinutes;   // or int, depending on your needs
  double totalCalories;  // or int
  // ... keep your existing fields (weight, height, etc.)

  UserStats({
    this.age = 0,
    this.gender = '',
    this.totalWorkouts = 0,
    this.totalMinutes = 0.0,
    this.totalCalories = 0.0,
    // ... existing parameters
  });

  // If you have fromJson/toJson, add the new fields:
  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    age: json['age'] ?? 0,
    gender: json['gender'] ?? '',
    totalWorkouts: json['totalWorkouts'] ?? 0,
    totalMinutes: (json['totalMinutes'] ?? 0).toDouble(),
    totalCalories: (json['totalCalories'] ?? 0).toDouble(),
    // ... existing fields
  );

  Map<String, dynamic> toJson() => {
    'age': age,
    'gender': gender,
    'totalWorkouts': totalWorkouts,
    'totalMinutes': totalMinutes,
    'totalCalories': totalCalories,
    // ... existing fields
  };

  // Add copyWith if you use it:
  UserStats copyWith({
    int? age,
    String? gender,
    int? totalWorkouts,
    double? totalMinutes,
    double? totalCalories,
    // ... existing fields
  }) => UserStats(
    age: age ?? this.age,
    gender: gender ?? this.gender,
    totalWorkouts: totalWorkouts ?? this.totalWorkouts,
    totalMinutes: totalMinutes ?? this.totalMinutes,
    totalCalories: totalCalories ?? this.totalCalories,
    // ... existing fields
  );
}
