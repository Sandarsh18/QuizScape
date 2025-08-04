// lib/main.dart
import 'package:flutter/material.dart';
import 'package:quiz_app/screens/category_screen.dart';
import 'package:quiz_app/screens/login_screen.dart';
<<<<<<< HEAD
import 'package:quiz_app/services/auth_service.dart';
import 'package:quiz_app/utils/theme.dart';

void main() {
  runApp(const MyApp());
=======
import 'package:quiz_app/screens/profile_screen.dart';
import 'package:quiz_app/screens/question_screen.dart';
import 'package:quiz_app/screens/result_screen.dart';
import 'package:quiz_app/services/auth_service.dart';
import 'package:quiz_app/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/utils/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
>>>>>>> master
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: appTheme(),
      debugShowCheckedModeBanner: false,
      home: _getInitialScreen(),
=======
  // It's better to not create a new instance on every build.
  static final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final lightTheme = appTheme();
    final darkTheme = appDarkTheme();
    return MaterialApp(
      title: 'Quiz App',
      theme: lightTheme.copyWith(
        textTheme: lightTheme.textTheme.apply(bodyColor: Colors.black, displayColor: Colors.black),
      ),
      darkTheme: darkTheme.copyWith(
        textTheme: darkTheme.textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
      ),
      themeMode: themeNotifier.themeMode,
      debugShowCheckedModeBanner: false,
      home: _getInitialScreen(),
      routes: {
        '/profile': (context) => const ProfileScreen(),
        '/question': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return QuestionScreen(
            category: args['category'] as String,
            difficulty: args['difficulty'] as String,
          );
        },
        '/result': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return ResultScreen(
            score: args['score'] as int,
            totalQuestions: args['totalQuestions'] as int,
            category: args['category'] as String,
            difficulty: args['difficulty'] as String,
          );
        },
      },
>>>>>>> master
    );
  }

  Widget _getInitialScreen() {
    // In a real app, this might be a splash screen that checks auth status
<<<<<<< HEAD
    final AuthService authService = AuthService();
    return FutureBuilder(
      future: authService.getCurrentUser(),
=======
    return FutureBuilder(
      future: _authService.getCurrentUser(),
>>>>>>> master
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const CategoryScreen();
        }
        return const LoginScreen();
      },
    );
  }
}