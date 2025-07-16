// lib/services/quiz_service.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/question.dart';

class QuizService {
  Future<List<Question>> getQuestionsForCategory(String categoryName) async {
    final String response = await rootBundle.loadString('assets/data/quiz_questions.json');
    final data = await json.decode(response);
    final category = (data['categories'] as List).firstWhere(
      (cat) => cat['name'] == categoryName,
      orElse: () => null,
    );

    if (category != null) {
      final List<dynamic> questionsJson = category['questions'];
      return questionsJson.map((json) => Question.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<String>> getCategories() async {
    final String response = await rootBundle.loadString('assets/data/quiz_questions.json');
    final data = await json.decode(response);
    return (data['categories'] as List).map((cat) => cat['name'] as String).toList();
  }
    
  List<Question> getRandomQuestions(List<Question> allQuestions, int count) {
    final shuffled = List<Question>.from(allQuestions)..shuffle();
    return shuffled.take(count).toList();
  }
}