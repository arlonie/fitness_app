import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'profile_screen.dart'; // Import the new ProfileScreen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  // Fetch user data for personalized greeting
  Future<UserModel?> _fetchUserData() async {
    final user =
        _authService.currentUser; // Assuming AuthService has currentUser getter
    if (user != null) {
      final snapshot = await _authService.database
          .child('users/${user.uid}')
          .once();
      final data = snapshot.snapshot.value;
      if (data != null) {
        return UserModel.fromJson(Map<String, dynamic>.from(data as Map));
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: isDarkTheme
      //       ? Colors.deepPurple[900]
      //       : Colors.deepPurple,
      //   foregroundColor: Colors.white,
      //   elevation: 0,
      //   centerTitle: false,
      // ),
      backgroundColor: isDarkTheme ? Colors.black87 : Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkTheme
                ? [Colors.black87, Colors.grey[900]!]
                : [Colors.white, Colors.grey[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FutureBuilder<UserModel?>(
              future: _fetchUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final user = snapshot.data;
                final greeting = user != null
                    ? "Hello, ${user.firstname}!"
                    : "Hello, Athlete!";

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Section with user avatar
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.15),
                            child: Icon(
                              Icons.person,
                              size: 36,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                greeting,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: isDarkTheme
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              Text(
                                "Let's crush today's goals! 💪",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDarkTheme
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Weekly Stats Section
                    Text(
                      "This Week",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDarkTheme ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Quick Stats Cards (3 column grid)
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            label: "Workouts",
                            value: "3/5",
                            icon: Icons.fitness_center,
                            progress: 0.6,
                            isDarkTheme: isDarkTheme,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            label: "Calories",
                            value: "1.2k",
                            icon: Icons.fire_truck,
                            progress: 0.75,
                            isDarkTheme: isDarkTheme,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            label: "Water",
                            value: "6/8",
                            icon: Icons.local_drink,
                            progress: 0.75,
                            isDarkTheme: isDarkTheme,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Feature Cards
                    Text(
                      "Explore Features",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDarkTheme ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: ListView(
                        children: [
                          _buildFeatureCard(
                            context,
                            title: "Track Your Progress",
                            subtitle: "Monitor your fitness journey",
                            icon: Icons.bar_chart,
                            onTap: () =>
                                _showFeatureSnackBar(context, "Track Progress"),
                            color: const Color(0xFF4CAF50),
                            isDarkTheme: isDarkTheme,
                          ),
                          _buildFeatureCard(
                            context,
                            title: "Set Your Goals",
                            subtitle: "Define your targets and milestones",
                            icon: Icons.flag,
                            onTap: () =>
                                _showFeatureSnackBar(context, "Set Goals"),
                            color: const Color(0xFF2196F3),
                            isDarkTheme: isDarkTheme,
                          ),
                          _buildFeatureCard(
                            context,
                            title: "Workout Plans",
                            subtitle: "Personalized routines for you",
                            icon: Icons.fitness_center,
                            onTap: () =>
                                _showFeatureSnackBar(context, "Workout Plans"),
                            color: const Color(0xFFFF9800),
                            isDarkTheme: isDarkTheme,
                          ),
                          _buildFeatureCard(
                            context,
                            title: "Nutrition Tips",
                            subtitle: "Fuel your body right",
                            icon: Icons.restaurant,
                            onTap: () =>
                                _showFeatureSnackBar(context, "Nutrition Tips"),
                            color: const Color(0xFFF44336),
                            isDarkTheme: isDarkTheme,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required double progress,
    required bool isDarkTheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon with background
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: isDarkTheme
                  ? Colors.grey[700]
                  : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDarkTheme ? Colors.white54 : Colors.black54,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required bool isDarkTheme,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withValues(alpha: 0.08),
          highlightColor: color.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                // Icon with gradient background
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.2),
                        color.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 16),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDarkTheme ? Colors.white : Colors.black87,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDarkTheme ? Colors.white54 : Colors.black54,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.arrow_forward_ios, size: 16, color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFeatureSnackBar(BuildContext context, String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("$feature feature coming soon!")));
  }
}
