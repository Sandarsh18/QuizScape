// lib/main.dart
import 'package:flutter/material.dart';
import 'package:quiz_app/screens/category_screen.dart';
import 'package:quiz_app/screens/login_screen.dart';
import 'package:quiz_app/screens/profile_screen.dart';
import 'package:quiz_app/screens/question_screen.dart';
// import 'package:quiz_app/screens/result_screen.dart'; // Removed unused import
import 'package:quiz_app/screens/quiz_result_screen.dart';
import 'package:quiz_app/services/supabase_service.dart';
import 'package:quiz_app/utils/theme.dart';

import 'package:provider/provider.dart';
import 'package:quiz_app/utils/theme_notifier.dart';

// Add flutter_dotenv for environment variable management
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from .env file in assets/ (required for Flutter web)
  // Make sure to create assets/.env (see assets/.env.example)
  await dotenv.load(fileName: "assets/.env");
  // Initialize Supabase with credentials from .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
//
// --- ENVIRONMENT SETUP INSTRUCTIONS ---
//
// 1. Copy assets/.env.example to assets/.env
// 2. Fill in your Supabase credentials in assets/.env:
//      SUPABASE_URL=your-project-url
//      SUPABASE_ANON_KEY=your-anon-key
// 3. Do NOT commit assets/.env to version control (see .gitignore).
// 4. This setup works for Android, iOS, and Web builds.
//
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final SupabaseService _supabaseService = SupabaseService();

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
        '/quiz': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return QuestionScreen(
            category: args['category'] as String,
            difficulty: args['difficulty'] as String,
          );
        },
        '/quiz_result': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return QuizResultScreen(
            score: args['score'] as int,
            totalQuestions: args['totalQuestions'] as int,
            category: args['category'] as String,
            difficulty: args['difficulty'] as String,
          );
        },
      },
    );
  }

  Widget _getInitialScreen() {
    // Use Supabase Auth session to determine if user is logged in
    final user = _supabaseService.currentUser;
    if (user != null) {
      return const CategoryScreen();
    } else {
      return const LoginScreen();
    }
  }
}


// --- Example usage of SupabaseService (for reference only, do not run in main.dart) ---
//
// final supabaseService = SupabaseService();
//
// // Sign up a user
// final authRes = await supabaseService.signUp('email@example.com', 'password123');
// final user = authRes.user;
// if (user != null) {
//   await supabaseService.createUser(
//     id: user.id,
//     username: username, // <-- use 'username'
//    email: email,
//   );
// }
//
// // Sign in a user
// final signInRes = await supabaseService.signIn('email@example.com', 'password123');
// final signedInUser = signInRes.user;
//
// // Create a quiz
// await supabaseService.createQuiz(
//   title: 'General Knowledge',
//   category: 'General',
//   difficulty: 'Easy',
//   questions: [
//     {'question': 'What is 2+2?', 'options': ['3', '4', '5'], 'answer': '4'},
//   ],
//   createdBy: signedInUser!.id,
// );
//
// --- RLS and SQL policies must be set up in the Supabase dashboard or SQL editor, not in Dart code. ---