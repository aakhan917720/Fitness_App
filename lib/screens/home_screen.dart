import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../login_and_sign_up/login.dart';
import '../services/firestore_service.dart';
import 'exercises_screen.dart';
import 'progress_screen.dart';
import 'bmi_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const ExercisesScreen(),
    const ProgressScreen(),
    const BMIScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Exercises',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'BMI',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(  // ← Yeh add karo
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Logout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, Fitness Warrior!',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Let's crush your goals today",
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () async {
                          bool? confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Logout'),
                              content: const Text('Are you sure you want to logout?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await FirebaseAuth.instance.signOut();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const Login()),
                                  (route) => false,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.logout,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ===== STATS CARDS - STREAMBUILDER =====
                  StreamBuilder<QuerySnapshot>(
                    stream: FirestoreService().getTodayWorkouts(),
                    builder: (context, snapshot) {
                      // Debug prints
                      print('=== TODAY STATS ===');
                      print('Connection: ${snapshot.connectionState}');
                      print('Has data: ${snapshot.hasData}');
                      print('Has error: ${snapshot.hasError}');
                      if (snapshot.hasError) {
                        print('Error: ${snapshot.error}');
                      }
                      if (snapshot.hasData) {
                        print('Docs count: ${snapshot.data!.docs.length}');
                      }

                      int todayCalories = 0;
                      int todayMinutes = 0;
                      int todayWorkouts = 0;

                      if (snapshot.hasData && snapshot.data != null) {
                        for (var doc in snapshot.data!.docs) {
                          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                          print('Doc data: $data');

                          var cal = data['caloriesBurned'];
                          var dur = data['duration'];

                          if (cal != null) {
                            todayCalories += cal is int ? cal : (cal as num).toInt();
                          }
                          if (dur != null) {
                            todayMinutes += (dur is int ? dur : (dur as num).toInt()) ~/ 60;
                          }
                          todayWorkouts++;
                        }
                      }

                      print('Stats: C=$todayCalories, M=$todayMinutes, W=$todayWorkouts');

                      return Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Calories',
                              '$todayCalories',
                              'kcal',
                              Icons.local_fire_department,
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Minutes',
                              '$todayMinutes',
                              'min',
                              Icons.timer,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Workouts',
                              '$todayWorkouts',
                              'done',
                              Icons.check_circle,
                              Colors.blue,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Quick Start
                  Text(
                    'Quick Start',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickStartCard(context),
                  const SizedBox(height: 24),

                  // Categories
                  Text(
                    'Categories',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCategoryChip(context, 'All', Icons.apps),
                        _buildCategoryChip(context, 'Cardio', Icons.directions_run),
                        _buildCategoryChip(context, 'Strength', Icons.fitness_center),
                        _buildCategoryChip(context, 'Core', Icons.accessibility_new),
                        _buildCategoryChip(context, 'HIIT', Icons.flash_on),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== RECENT WORKOUTS - STREAMBUILDER =====
                  Text(
                    'Recent Workouts',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirestoreService().getAllWorkouts(),
                    builder: (context, snapshot) {
                      print('=== RECENT WORKOUTS ===');
                      print('Connection: ${snapshot.connectionState}');
                      print('Has data: ${snapshot.hasData}');
                      print('Has error: ${snapshot.hasError}');

                      if (snapshot.hasError) {
                        print('Error: ${snapshot.error}');
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
                        print('No workouts found');
                        return _buildEmptyState(context);
                      }

                      print('Found ${snapshot.data!.docs.length} workouts');

                      // Sort locally
                      var docs = snapshot.data!.docs;
                      docs.sort((a, b) {
                        var aData = a.data() as Map<String, dynamic>;
                        var bData = b.data() as Map<String, dynamic>;
                        var aTime = aData['completedAt'] ?? aData['date'];
                        var bTime = bData['completedAt'] ?? bData['date'];
                        if (aTime is Timestamp && bTime is Timestamp) {
                          return bTime.compareTo(aTime);
                        }
                        return 0;
                      });

                      var recentDocs = docs.take(5).toList();

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentDocs.length,
                        itemBuilder: (context, index) {
                          Map<String, dynamic> data = recentDocs[index].data() as Map<String, dynamic>;

                          var timestamp = data['completedAt'] ?? data['date'];
                          DateTime date;
                          if (timestamp is Timestamp) {
                            date = timestamp.toDate();
                          } else {
                            date = DateTime.now();
                          }

                          var exerciseName = data['exerciseName'] ?? 'Workout';
                          var duration = data['duration'] ?? 0;
                          var calories = data['caloriesBurned'] ?? 0;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF6C63FF).withOpacity(0.1),
                                child: const Icon(Icons.fitness_center, color: Color(0xFF6C63FF)),
                              ),
                              title: Text(exerciseName.toString()),
                              subtitle: Text(
                                '${(duration is int ? duration : (duration as num).toInt()) ~/ 60} min • ${calories is int ? calories : (calories as num).toInt()} kcal',
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  if (data['locationName'] != null)
                                    Text(
                                      data['locationName'].toString(),
                                      style: TextStyle(
                                        color: Colors.green.shade600,
                                        fontSize: 10,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods same hain...
  Widget _buildStatCard(String title, String value, String unit, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ExercisesScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Start Workout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose from 8+ exercises',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const ExercisesScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6C63FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Start Now'),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.play_circle_fill,
              size: 80,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ExercisesScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No workouts yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your first workou today!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}