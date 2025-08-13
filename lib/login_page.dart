import 'package:flutter/material.dart';
import 'services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String _status = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase Auth")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Pasword"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final user = await _authService.signIn(
                  _emailController.text,
                  _passwordController.text,
                );
                setState(() {
                  _status = user != null
                      ? "Logged in a ${user.email}"
                      : "Login failed";
                });
              },
              child: const Text("Sign In"),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = await _authService.signUp(
                  _emailController.text,
                  _passwordController.text,
                );
                setState(() {
                  _status = user != null
                      ? "Account created for ${user.email}"
                      : "Sign up failed";
                });
              },
              child: const Text("Sign Up"),
            ),
            const SizedBox(height: 20),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
