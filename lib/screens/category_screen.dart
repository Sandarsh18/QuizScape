// lib/screens/category_screen.dart
import 'package:flutter/material.dart';
import 'package:quiz_app/screens/profile_screen.dart';
import 'package:quiz_app/screens/question_screen.dart';
import 'package:quiz_app/services/quiz_service.dart';
import 'package:quiz_app/widgets/gradient_background.dart';

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
                  color: Colors.primaries[index % Colors.primaries.length].shade200,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => QuestionScreen(category: category),
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                      child: Center(
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                            shadows: [Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(1,1))],
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