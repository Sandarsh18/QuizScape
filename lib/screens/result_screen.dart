// lib/screens/result_screen.dart
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:quiz_app/models/quiz_result.dart';
import 'package:quiz_app/services/storage_service.dart';
=======
import 'package:quiz_app/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/utils/theme_notifier.dart';
>>>>>>> master

class ResultScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final String category;
<<<<<<< HEAD
=======
  final String difficulty;
>>>>>>> master

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.category,
<<<<<<< HEAD
=======
    required this.difficulty,
>>>>>>> master
  });

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
<<<<<<< HEAD
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _saveResult();
  }

  void _saveResult() async {
    final user = await _storageService.getUser();
    if (user != null) {
      final result = QuizResult(
        category: widget.category,
        score: widget.score,
        totalQuestions: widget.totalQuestions,
        date: DateTime.now(),
      );
      user.quizHistory.add(result);
      await _storageService.saveUser(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF43CEA2), Color(0xFF185A9D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
=======

  @override
  Widget build(BuildContext context) {
    print('ResultScreen received category: ${widget.category}, difficulty: ${widget.difficulty}');
    final categoryColor = AppColors.categoryColors[widget.category] ?? Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: categoryColor,
        elevation: 0,
        title: Text('${widget.category} - ${widget.difficulty[0].toUpperCase()}${widget.difficulty.substring(1)}'),
        actions: [
          Consumer<ThemeNotifier>(
            builder: (context, themeNotifier, _) {
              final isDark = themeNotifier.themeMode == ThemeMode.dark;
              return IconButton(
                icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () => themeNotifier.toggleTheme(),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
         color: categoryColor.withOpacity(0.1),
>>>>>>> master
        ),
        child: Center(
          child: Card(
            elevation: 16,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
<<<<<<< HEAD
            color: Colors.white.withOpacity(0.95),
=======
           color: categoryColor.withOpacity(0.95),
>>>>>>> master
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Quiz Complete!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
<<<<<<< HEAD
                      color: Colors.green,
=======
                      color: Colors.greenAccent,
>>>>>>> master
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your Score: ${widget.score} / ${widget.totalQuestions}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 22,
<<<<<<< HEAD
                      color: Colors.blueAccent,
=======
                      color: Theme.of(context).colorScheme.secondary,
>>>>>>> master
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
<<<<<<< HEAD
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 8,
                    ),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Play Again', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
=======
                  Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 8,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacementNamed(
                            '/question',
                            arguments: {
                              'category': widget.category,
                              'difficulty': widget.difficulty,
                            },
                          );
                        },
                        child: const Text('Play Same Quiz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Theme.of(context).colorScheme.onSecondary,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 8,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed('/profile');
                        },
                        child: const Text('Go to Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 8,
                        ),
                        onPressed: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        },
                        child: const Text('Go to Home', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
>>>>>>> master
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