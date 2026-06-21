import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../modals/exercise.dart';
import '../providers/fitness_provider.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';

class WorkoutScreen extends StatefulWidget {
  final Exercise exercise;

  const WorkoutScreen({super.key, required this.exercise});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  Timer? _timer;
  bool _isPaused = false;
  Position? _currentPosition;
  String? _locationName;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _getLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FitnessProvider>().startWorkout(widget.exercise);
      _startTimer();
    });
  }

  // Get user location
  Future<void> _getLocation() async {
    Position? position = await LocationService.getCurrentPosition();
    if (position != null) {
      String? address = await LocationService.getAddressFromPosition(position);
      setState(() {
        _currentPosition = position;
        _locationName = address;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        context.read<FitnessProvider>().incrementWorkoutTime();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Complete workout and save to Firestore
  void _completeWorkout() async {
    _timer?.cancel();

    final provider = context.read<FitnessProvider>();
    final seconds = provider.currentWorkoutSeconds;
    final calories = (widget.exercise.calories * seconds / widget.exercise.duration).round();

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Save to Firestore with location
      await _firestoreService.saveWorkout(
        exerciseId: widget.exercise.id,
        exerciseName: widget.exercise.name,
        category: widget.exercise.category,
        duration: seconds,
        caloriesBurned: calories,
        latitude: _currentPosition?.latitude,
        longitude: _currentPosition?.longitude,
        locationName: _locationName,
      );

      // Complete in provider
      provider.completeWorkout();

      // Hide loading
      Navigator.pop(context);

      // Show success
      _showCompletionDialog(calories, seconds);
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving workout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _showExitDialog();
        return false;
      },
      child: Scaffold(
        body: Consumer<FitnessProvider>(
          builder: (context, provider, child) {
            final progress = provider.currentWorkoutSeconds / widget.exercise.duration;
            final calories = (widget.exercise.calories * provider.currentWorkoutSeconds / widget.exercise.duration).round();

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Top Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _showExitDialog,
                          icon: const Icon(Icons.close),
                        ),
                        Text(
                          widget.exercise.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),

                    // Location Display
                    if (_locationName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              _locationName!,
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 30),

                    // Timer Circle
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: CircularProgressIndicator(
                            value: progress > 1 ? 1 : progress,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              _formatTime(provider.currentWorkoutSeconds),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '/ ${_formatTime(widget.exercise.duration)}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatCard('Calories', '$calories', Icons.local_fire_department, Colors.orange),
                        const SizedBox(width: 20),
                        _buildStatCard('Location', _locationName ?? 'Getting...', Icons.location_on, Colors.green),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Steps
                    const Text(
                      'Steps:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.exercise.steps.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Color(0xFF6C63FF),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.exercise.steps[index],
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isPaused = !_isPaused;
                              });
                            },
                            icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                            label: Text(_isPaused ? 'Resume' : 'Pause'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _completeWorkout,
                            icon: const Icon(Icons.check),
                            label: const Text('Complete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Workout?'),
        content: const Text('Your progress will be lost if you exit now.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              _timer?.cancel();
              context.read<FitnessProvider>().cancelWorkout();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(int calories, int seconds) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Workout Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.celebration, size: 64, color: Color(0xFF6C63FF)),
            const SizedBox(height: 16),
            Text(
              'Great job completing ${widget.exercise.name}!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Calories: $calories | Duration: ${seconds ~/ 60} min',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (_locationName != null)
              Text(
                'Location: $_locationName',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }
}