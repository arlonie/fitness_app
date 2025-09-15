import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fitness App',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.light(
          primary: Colors.yellowAccent.shade700,
          secondary: Colors.blueAccent,
          surface: Colors.white,
          onSurface: Colors.black87,
        ),
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.dark(
          primary: Colors.yellowAccent.shade700,
          secondary: Colors.blueAccent,
          surface: Colors.grey[850]!,
          onSurface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.black,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
      themeMode: ThemeMode.system, // Respect system theme
      home: const Wrapper(),
    );
  }
}
