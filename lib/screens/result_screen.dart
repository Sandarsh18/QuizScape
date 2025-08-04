// lib/screens/result_screen.dart
import 'package:flutter/material.dart';
import 'package:quiz_app/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/utils/theme_notifier.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;
  final String category;
  final String difficulty;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.category,
    required this.difficulty,
  });

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {

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
        ),
        child: Center(
          child: Card(
            elevation: 16,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
           color: categoryColor.withOpacity(0.95),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Quiz Complete!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your Score: ${widget.score} / ${widget.totalQuestions}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 22,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
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