import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for inputFormatters
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _goalController;

  bool _isSaving = false;

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

      await _userService.updateUserProfile(currentUser.id, updates);

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
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: "Log Out",
            color: Colors.redAccent,
          ),
        ],
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
                        maxLength: 50,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\s]'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _firstnameController.value = _firstnameController
                                .value
                                .copyWith(
                                  text:
                                      value[0].toUpperCase() +
                                      value.substring(1).toLowerCase(),
                                );
                          }
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "First name is required";
                          }
                          if (value.trim().length > 50) {
                            return "First name must be 50 characters or less";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Lastname
                      TextFormField(
                        controller: _lastnameController,
                        decoration: _buildInputDecoration(
                          "Last Name",
                          isDarkTheme,
                        ),
                        maxLength: 50,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\s]'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            _lastnameController.value = _lastnameController
                                .value
                                .copyWith(
                                  text:
                                      value[0].toUpperCase() +
                                      value.substring(1).toLowerCase(),
                                );
                          }
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Last name is required";
                          }
                          if (value.trim().length > 50) {
                            return "Last name must be 50 characters or less";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Height
                      TextFormField(
                        controller: _heightController,
                        decoration:
                            _buildInputDecoration(
                              "Height (cm)",
                              isDarkTheme,
                            ).copyWith(
                              prefixIcon: Icon(
                                Icons.straighten,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                        maxLength: 5,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty &&
                              !RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                            _heightController.value = _heightController.value
                                .copyWith(
                                  text: value.replaceAll(
                                    RegExp(r'[^0-9.]'),
                                    '',
                                  ),
                                );
                          }
                        },
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Height is required";
                          }
                          final num = double.tryParse(value.trim());
                          if (num == null) {
                            return "Invalid height";
                          }
                          if (num < 100 || num > 250) {
                            return "Height must be between 100-250 cm";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Weight
                      TextFormField(
                        controller: _weightController,
                        decoration:
                            _buildInputDecoration(
                              "Weight (kg)",
                              isDarkTheme,
                            ).copyWith(
                              prefixIcon: Icon(
                                Icons.monitor_weight,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                        maxLength: 5,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty &&
                              !RegExp(r'^\d*\.?\d*$').hasMatch(value)) {
                            _weightController.value = _weightController.value
                                .copyWith(
                                  text: value.replaceAll(
                                    RegExp(r'[^0-9.]'),
                                    '',
                                  ),
                                );
                          }
                        },
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Weight is required";
                          }
                          final num = double.tryParse(value.trim());
                          if (num == null) {
                            return "Invalid weight";
                          }
                          if (num < 30 || num > 200) {
                            return "Weight must be between 30-200 kg";
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
                        maxLength: 100,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(
                              r'[a-zA-Z0-9\s.,!-]',
                            ), // Allows letters, numbers, spaces, and basic punctuation
                          ),
                        ],
                        validator: (value) {
                          if (value != null && value.trim().length > 100) {
                            return "Goal must be 100 characters or less";
                          }
                          return null;
                        },
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
      hintText: "Enter your $label",
      hintStyle: TextStyle(
        color: isDarkTheme ? Colors.white54 : Colors.black45,
      ),
      filled: true,
      fillColor: isDarkTheme ? Colors.grey[800] : Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(
        vertical: 18.0,
        horizontal: 16.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 14.0),
    );
  }
}
