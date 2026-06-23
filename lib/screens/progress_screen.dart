import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress'), centerTitle: true),
      body: Consumer<FitnessProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverallStats(context, provider),
                const SizedBox(height: 24),
                const Text('Weekly Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildWeeklyChart(),
                const SizedBox(height: 24),
                const Text('All Time Stats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildAllTimeStats(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverallStats(BuildContext context, FitnessProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('Total Progress', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressItem('${provider.userStats.totalWorkouts}', 'Workouts', Icons.fitness_center),
              _buildProgressItem('${provider.userStats.totalCalories}', 'Calories', Icons.local_fire_department),
              _buildProgressItem('${provider.userStats.totalMinutes}', 'Minutes', Icons.timer),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildBar('Mon', 0.3),
          _buildBar('Tue', 0.6),
          _buildBar('Wed', 0.4),
          _buildBar('Thu', 0.8),
          _buildBar('Fri', 0.5),
          _buildBar('Sat', 0.9),
          _buildBar('Sun', 0.2),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 150 * height,
          decoration: BoxDecoration(color: const Color(0xFF6C63FF), borderRadius: BorderRadius.circular(8)),
        ),
        const SizedBox(height: 8),
        Text(day, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildAllTimeStats(BuildContext context, FitnessProvider provider) {
    return Column(
      children: [
        _buildStatTile('Current Weight', '${provider.userStats.weight} kg', Icons.monitor_weight, Colors.blue),
        const SizedBox(height: 12),
        _buildStatTile('Height', '${provider.userStats.height} cm', Icons.height, Colors.green),
        const SizedBox(height: 12),
        _buildStatTile('BMI', provider.userStats.bmi.toStringAsFixed(1), Icons.calculate, _getBMIColor(provider.userStats.bmi)),
        const SizedBox(height: 12),
        _buildStatTile('Age', '${provider.userStats.age} years', Icons.cake, Colors.purple),
      ],
    );
  }

  Widget _buildStatTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }
}