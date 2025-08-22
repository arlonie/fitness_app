import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _loading = false;

  // Validation states
  bool _isEmailValid = false;
  bool _isConfirmPasswordValid = false;
  bool _isPasswordValid = false;
  bool _isFirstnameValid = false;
  bool _isLastnameValid = false;

  /// Simple email regex validator
  bool _validateEmailFormat(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  void _onEmailChanged(String value) {
    setState(() => _isEmailValid = _validateEmailFormat(value.trim()));
  }

  void _onPasswordChanged(String value) {
    setState(() => _isPasswordValid = value.trim().length >= 6);
    _checkConfirmPassword();
  }

  void _onConfirmPasswordChanged(String _) {
    _checkConfirmPassword();
  }

  void _checkConfirmPassword() {
    final p = _passwordController.text.trim();
    final c = _confirmPasswordController.text.trim();
    setState(() => _isConfirmPasswordValid = c.isNotEmpty && p == c);
  }

  void _onFirstnameChanged(String value) {
    setState(() => _isFirstnameValid = value.trim().isNotEmpty);
  }

  void _onLastnameChanged(String value) {
    setState(() => _isLastnameValid = value.trim().isNotEmpty);
  }

  bool get _isFormValid =>
      _isFirstnameValid &&
      _isLastnameValid &&
      _isEmailValid &&
      _isPasswordValid &&
      _isConfirmPasswordValid;

  void _signUp() async {
    if (!_isFormValid) return;

    setState(() {
      _loading = true;
    });

    try {
      final user = await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        firstname: _firstnameController.text.trim(),
        lastname: _lastnameController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Account created! Check your inbox or spam to verify your email.",
            ),
            duration: Duration(seconds: 4),
          ),
        );

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);

      String message = "Sign-up failed. Please try again.";

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case "invalid-email":
            message = "That email address is invalid.";
            break;
          case "weak-password":
            message = "Password should be at least 6 characters.";
            break;
          case "email-already-in-use":
            message = "That email is already registered. Try logging in.";
            break;
          default:
            message = e.message ?? "Sign-up failed.";
        }
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.pinkAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) =>
                        Transform.scale(scale: value, child: child),
                    child: const Icon(
                      Icons.fitness_center,
                      size: 100,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Join the Fitness Journey!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Create your account to start tracking your goals",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Firstname & Lastname
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _firstnameController,
                          onChanged: _onFirstnameChanged,
                          decoration: InputDecoration(
                            hintText: "First Name",
                            prefixIcon: const Icon(Icons.person),
                            suffixIcon: _firstnameController.text.isEmpty
                                ? null
                                : Icon(
                                    _isFirstnameValid
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: _isFirstnameValid
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _lastnameController,
                          onChanged: _onLastnameChanged,
                          decoration: InputDecoration(
                            hintText: "Last Name",
                            prefixIcon: const Icon(Icons.person_outline),
                            suffixIcon: _lastnameController.text.isEmpty
                                ? null
                                : Icon(
                                    _isLastnameValid
                                        ? Icons.check_circle
                                        : Icons.error,
                                    color: _isLastnameValid
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  TextField(
                    controller: _emailController,
                    onChanged: _onEmailChanged,
                    decoration: InputDecoration(
                      hintText: "Email",
                      prefixIcon: const Icon(Icons.email),
                      suffixIcon: _emailController.text.isEmpty
                          ? null
                          : Icon(
                              _isEmailValid ? Icons.check_circle : Icons.error,
                              color: _isEmailValid ? Colors.green : Colors.red,
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    onChanged: _onPasswordChanged,
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: _passwordController.text.isEmpty
                          ? null
                          : Icon(
                              _isPasswordValid
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: _isPasswordValid
                                  ? Colors.green
                                  : Colors.red,
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Field
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    onChanged: _onConfirmPasswordChanged,
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: _confirmPasswordController.text.isEmpty
                          ? null
                          : Icon(
                              _isConfirmPasswordValid
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: _isConfirmPasswordValid
                                  ? Colors.green
                                  : Colors.red,
                            ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading || !_isFormValid
                          ? null
                          : _signUp, // disable until valid
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.yellowAccent.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Already have an account
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Log In",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.yellowAccent,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
