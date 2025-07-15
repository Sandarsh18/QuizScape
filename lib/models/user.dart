// lib/models/user.dart
import 'package:json_annotation/json_annotation.dart';
import 'quiz_result.dart';

part 'user.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  String username;
  String password; // Note: In a real app, never store passwords in plain text.
  List<QuizResult> quizHistory;

  User({
    required this.username,
    required this.password,
    this.quizHistory = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}