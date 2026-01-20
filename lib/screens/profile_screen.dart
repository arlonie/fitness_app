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
        title: const Text(
          "Profile",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: isDarkTheme
            ? Colors.deepPurple[900]
            : Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: "Log Out",
            color: Colors.redAccent,
          ),
        ],
      ),
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
                        // Profile Avatar with modern design
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.4),
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 62,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.15),
                            child: Icon(
                              Icons.person,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Email (non-editable)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkTheme
                                ? Colors.grey[850]
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.email_outlined,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkTheme
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Form Title
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Personal Information",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDarkTheme
                                  ? Colors.white
                                  : Colors.black87,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Firstname
                        TextFormField(
                          controller: _firstnameController,
                          style: TextStyle(
                            color: isDarkTheme ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: _buildModernInputDecoration(
                            "First Name",
                            Icons.person_outline,
                            isDarkTheme,
                            context,
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
                        const SizedBox(height: 14),

                        // Lastname
                        TextFormField(
                          controller: _lastnameController,
                          style: TextStyle(
                            color: isDarkTheme ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: _buildModernInputDecoration(
                            "Last Name",
                            Icons.person_outline,
                            isDarkTheme,
                            context,
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
                        const SizedBox(height: 20),

                        // Fitness Title
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Fitness Details",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDarkTheme
                                  ? Colors.white
                                  : Colors.black87,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Height & Weight Row
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _heightController,
                                style: TextStyle(
                                  color: isDarkTheme
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: _buildModernInputDecoration(
                                  "Height (cm)",
                                  Icons.straighten,
                                  isDarkTheme,
                                  context,
                                ),
                                maxLength: 5,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]'),
                                  ),
                                ],
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Required";
                                  }
                                  final num = double.tryParse(value.trim());
                                  if (num == null) {
                                    return "Invalid";
                                  }
                                  if (num < 100 || num > 250) {
                                    return "100-250cm";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _weightController,
                                style: TextStyle(
                                  color: isDarkTheme
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: _buildModernInputDecoration(
                                  "Weight (kg)",
                                  Icons.monitor_weight,
                                  isDarkTheme,
                                  context,
                                ),
                                maxLength: 5,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9.]'),
                                  ),
                                ],
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Required";
                                  }
                                  final num = double.tryParse(value.trim());
                                  if (num == null) {
                                    return "Invalid";
                                  }
                                  if (num < 30 || num > 200) {
                                    return "30-200kg";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Goal
                        TextFormField(
                          controller: _goalController,
                          style: TextStyle(
                            color: isDarkTheme ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: _buildModernInputDecoration(
                            "Fitness Goal",
                            Icons.flag_outlined,
                            isDarkTheme,
                            context,
                          ),
                          maxLength: 100,
                          minLines: 2,
                          maxLines: 3,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9\s.,!-]'),
                            ),
                          ],
                          validator: (value) {
                            if (value != null && value.trim().length > 100) {
                              return "Goal must be 100 characters or less";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        // Save Button with modern design
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.85),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _isSaving
                                  ? null
                                  : () => _saveProfile(user),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      "Save Changes",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3,
                                      ),
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
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String label,
    bool isDarkTheme,
    BuildContext context,
  ) {
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
      floatingLabelStyle: TextStyle(
        color: isDarkTheme ? Colors.white : Colors.black,
      ),
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

  InputDecoration _buildModernInputDecoration(
    String label,
    IconData icon,
    bool isDarkTheme,
    BuildContext context,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDarkTheme ? Colors.white54 : Colors.black54,
      ),
      hintStyle: TextStyle(
        fontSize: 14,
        color: isDarkTheme ? Colors.white38 : Colors.black38,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
          size: 20,
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      filled: true,
      fillColor: isDarkTheme ? Colors.grey[850] : Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 16.0,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          width: 1.2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDarkTheme
              ? Colors.grey[700]!.withValues(alpha: 0.5)
              : Colors.grey[300]!,
          width: 1.2,
        ),
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
        borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
      ),
      errorStyle: const TextStyle(
        color: Colors.redAccent,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
