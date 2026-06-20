import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fitness_provider.dart';

class BMIScreen extends StatefulWidget {
  const BMIScreen({super.key});

  @override
  State<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<FitnessProvider>();
    _weightController.text = provider.userStats.weight.toString();
    _heightController.text = provider.userStats.height.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        centerTitle: true,
      ),
      body: Consumer<FitnessProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildBMIDisplay(provider.userStats.bmi),
                const SizedBox(height: 32),
                _buildInputCard(
                  'Weight (kg)',
                  _weightController,
                  Icons.monitor_weight,
                ),
                const SizedBox(height: 16),
                _buildInputCard(
                  'Height (cm)',
                  _heightController,
                  Icons.height,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final weight = double.tryParse(_weightController.text);
                      final height = double.tryParse(_heightController.text);
                      if (weight != null && height != null) {
                        provider.updateUserStats(weight: weight, height: height);
                        FocusScope.of(context).unfocus();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Calculate BMI',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildBMICategories(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBMIDisplay(double bmi) {
    String category;
    Color color;
    String emoji;

    if (bmi < 18.5) {
      category = 'Underweight';
      color = Colors.blue;
      emoji = '🍽️';
    } else if (bmi < 25) {
      category = 'Normal Weight';
      color = Colors.green;
      emoji = '✅';
    } else if (bmi < 30) {
      category = 'Overweight';
      color = Colors.orange;
      emoji = '⚠️';
    } else {
      category = 'Obese';
      color = Colors.red;
      emoji = '🚨';
    }

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            bmi.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildBMICategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BMI Categories',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildCategoryRow('Underweight', '< 18.5', Colors.blue),
        _buildCategoryRow('Normal Weight', '18.5 - 24.9', Colors.green),
        _buildCategoryRow('Overweight', '25 - 29.9', Colors.orange),
        _buildCategoryRow('Obese', '≥ 30', Colors.red),
      ],
    );
  }

  Widget _buildCategoryRow(String label, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label),
          ),
          Text(
            range,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}