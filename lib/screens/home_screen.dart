import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

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

  void _logout(BuildContext context) async {
    await _authService.signOut();
    // Wrapper handles navigation via authStateChanges
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkTheme ? Colors.black : Colors.white,
      body: SafeArea(
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
                  // Header Section
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: isDarkTheme
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDarkTheme
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                          Text(
                            "Let's continue your fitness journey",
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkTheme
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Feature Cards
                  Expanded(
                    child: ListView(
                      children: [
                        _buildFeatureCard(
                          context,
                          title: "Track Your Progress",
                          icon: Icons.bar_chart,
                          onTap: () =>
                              _showFeatureSnackBar(context, "Track Progress"),
                        ),
                        _buildFeatureCard(
                          context,
                          title: "Set Your Goals",
                          icon: Icons.flag,
                          onTap: () =>
                              _showFeatureSnackBar(context, "Set Goals"),
                        ),
                        _buildFeatureCard(
                          context,
                          title: "Workout Plans",
                          icon: Icons.fitness_center,
                          onTap: () =>
                              _showFeatureSnackBar(context, "Workout Plans"),
                        ),
                        _buildFeatureCard(
                          context,
                          title: "Nutrition Tips",
                          icon: Icons.restaurant,
                          onTap: () =>
                              _showFeatureSnackBar(context, "Nutrition Tips"),
                        ),
                      ],
                    ),
                  ),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        "Log Out",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: isDarkTheme
                            ? Colors.black
                            : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: isDarkTheme
                            ? 0
                            : 6, // No elevation in dark mode
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkTheme ? Colors.grey[850] : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDarkTheme
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: .2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Icon(
              icon,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDarkTheme ? Colors.white : Colors.black87,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: isDarkTheme ? Colors.white70 : Colors.black54,
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
