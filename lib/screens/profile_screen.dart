import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart'; // Import the new UserService
import '../models/user_model.dart';
import 'login_screen.dart'; // For navigation after logout if needed

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService =
      UserService(); // Use UserService for profile updates
  final _formKey = GlobalKey<FormState>();

  // Controllers for editable fields
  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _goalController;

  bool _isLoading = false;
  bool _isSaving = false;

  // Fetch user data
  Future<UserModel?> _fetchUserData() async {
    final user = _authService.currentUser;
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
  void initState() {
    super.initState();
    // Initialize controllers (will be set in FutureBuilder)
    _firstnameController = TextEditingController();
    _lastnameController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _goalController = TextEditingController();
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _saveProfile(UserModel currentUser) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updates = {
        'firstname': _firstnameController.text.trim(),
        'lastname': _lastnameController.text.trim(),
        'height': double.tryParse(_heightController.text.trim()),
        'weight': double.tryParse(_weightController.text.trim()),
        'goal': _goalController.text.trim().isEmpty
            ? null
            : _goalController.text.trim(),
      };

      await _userService.updateUserProfile(
        currentUser.id,
        updates,
      ); // Use UserService

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update profile: $e")));
    }

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  void _logout() async {
    await _authService.signOut();
    // Wrapper will handle navigation, but to be safe:
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: isDarkTheme ? Colors.grey[900] : Colors.white,
        foregroundColor: isDarkTheme ? Colors.white : Colors.black87,
        elevation: 0,
      ),
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
              if (user == null) {
                return const Center(child: Text("Error loading profile"));
              }

              // Set controller values once data is loaded
              _firstnameController.text = user.firstname;
              _lastnameController.text = user.lastname;
              _heightController.text = user.height?.toString() ?? '';
              _weightController.text = user.weight?.toString() ?? '';
              _goalController.text = user.goal ?? '';

              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Avatar
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: isDarkTheme
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        child: Icon(
                          Icons.person,
                          size: 80,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email (non-editable)
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 18,
                          color: isDarkTheme ? Colors.white70 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Firstname
                      TextFormField(
                        controller: _firstnameController,
                        decoration: _buildInputDecoration(
                          "First Name",
                          isDarkTheme,
                        ),
                        validator: (value) =>
                            value!.trim().isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),

                      // Lastname
                      TextFormField(
                        controller: _lastnameController,
                        decoration: _buildInputDecoration(
                          "Last Name",
                          isDarkTheme,
                        ),
                        validator: (value) =>
                            value!.trim().isEmpty ? "Required" : null,
                      ),
                      const SizedBox(height: 16),

                      // Height
                      TextFormField(
                        controller: _heightController,
                        decoration: _buildInputDecoration(
                          "Height (cm)",
                          isDarkTheme,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.trim().isNotEmpty) {
                            if (double.tryParse(value) == null)
                              return "Invalid number";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Weight
                      TextFormField(
                        controller: _weightController,
                        decoration: _buildInputDecoration(
                          "Weight (kg)",
                          isDarkTheme,
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.trim().isNotEmpty) {
                            if (double.tryParse(value) == null)
                              return "Invalid number";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Goal
                      TextFormField(
                        controller: _goalController,
                        decoration: _buildInputDecoration(
                          "Fitness Goal",
                          isDarkTheme,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving
                              ? null
                              : () => _saveProfile(user),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24,
                            ),
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: isDarkTheme
                                ? Colors.black
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: isDarkTheme ? 0 : 6,
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "Save Changes",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _logout,
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
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: isDarkTheme ? 0 : 6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, bool isDarkTheme) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDarkTheme ? Colors.white70 : Colors.black54,
      ),
      filled: true,
      fillColor: isDarkTheme ? Colors.grey[800] : Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
