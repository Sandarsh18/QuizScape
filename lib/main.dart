
import 'package:flutter/material.dart';
import 'package:quiz_app/screens/category_screen.dart';
import 'package:quiz_app/screens/login_screen.dart';
import 'package:quiz_app/screens/profile_screen.dart';
import 'package:quiz_app/screens/question_screen.dart';
import 'package:quiz_app/screens/quiz_result_screen.dart';
import 'package:quiz_app/services/supabase_service.dart';
import 'package:quiz_app/utils/theme.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/utils/theme_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from assets/.env (see assets/.env.example)
  await dotenv.load(fileName: "assets/.env");
  // Initialize Supabase with credentials from .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
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

  // Returns the initial screen based on authentication state
  Widget _getInitialScreen() {
    final user = _supabaseService.currentUser;
    if (user != null) {
      return const CategoryScreen();
    } else {
      return const LoginScreen();
    }
  }
}