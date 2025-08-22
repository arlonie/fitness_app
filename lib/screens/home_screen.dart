import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) async {
    await AuthService().signOut();

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.pinkAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👤 Header Section
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.pinkAccent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Hello, Athlete! 💪",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Welcome back to your journey",
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 🌟 Feature Cards
                Expanded(
                  child: ListView(
                    children: [
                      _featureCard(
                        "Track Your Progress",
                        Icons.bar_chart,
                        Colors.blueAccent,
                        Colors.lightBlue,
                      ),
                      _featureCard(
                        "Set Your Goals",
                        Icons.flag,
                        Colors.orangeAccent,
                        Colors.deepOrange,
                      ),
                      _featureCard(
                        "Workout Plans",
                        Icons.fitness_center,
                        Colors.green,
                        Colors.lightGreen,
                      ),
                      _featureCard(
                        "Nutrition Tips",
                        Icons.restaurant,
                        Colors.purpleAccent,
                        Colors.deepPurple,
                      ),
                    ],
                  ),
                ),

                // 🚪 Logout Button
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.yellowAccent.shade700,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _featureCard(
    String title,
    IconData icon,
    Color startColor,
    Color endColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [startColor, endColor]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: startColor.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 36),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white70,
          size: 18,
        ),
        onTap: () {
          // 🚀 Navigate to specific feature page
        },
      ),
    );
  }
}
