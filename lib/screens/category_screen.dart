// lib/screens/category_screen.dart
import 'package:flutter/material.dart';
import 'package:quiz_app/screens/profile_screen.dart';
import 'package:quiz_app/screens/question_screen.dart';
import 'package:quiz_app/services/quiz_service.dart';
import 'package:quiz_app/widgets/gradient_background.dart';
import 'package:quiz_app/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/utils/theme_notifier.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final QuizService _quizService = QuizService();
  late Future<List<String>> _categories;

  @override
  void initState() {
    super.initState();
    _categories = _quizService.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Category'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
          ),
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
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: FutureBuilder<List<String>>(
          future: _categories,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No categories found.'));
            }

            final categories = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  color: AppColors.categoryColors[category] ?? Theme.of(context).cardColor,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () async {
                      final difficulty = await showDialog<String>(
                        context: context,
                        builder: (context) {
                          return SimpleDialog(
                            title: const Text('Select Difficulty'),
                            children: QuizService().getDifficulties().map((level) =>
                              SimpleDialogOption(
                                onPressed: () => Navigator.pop(context, level),
                                child: Text(level[0].toUpperCase() + level.substring(1)),
                              )
                            ).toList(),
                          );
                        },
                      );
                      if (difficulty != null) {
                        print('Navigating to QuestionScreen with category: $category, difficulty: $difficulty');
                        Navigator.of(context).pushNamed(
                          '/question',
                          arguments: {
                            'category': category,
                            'difficulty': difficulty,
                          },
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                      child: Center(
                        child: Text(
                          category,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            shadows: [const Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(1,1))],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}