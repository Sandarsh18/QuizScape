// lib/models/quiz_result.dart
import 'package:json_annotation/json_annotation.dart';

part 'quiz_result.g.dart';

@JsonSerializable()
class QuizResult {
  final String category;
  final int score;
  final int totalQuestions;
  final DateTime date;

  QuizResult({
    required this.category,
    required this.score,
    required this.totalQuestions,
    required this.date,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) => _$QuizResultFromJson(json);
  Map<String, dynamic> toJson() => _$QuizResultToJson(this);
}