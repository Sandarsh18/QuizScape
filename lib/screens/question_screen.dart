// lib/screens/question_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quiz_app/models/question.dart';
import 'package:quiz_app/services/quiz_service.dart';
import 'package:quiz_app/services/supabase_service.dart';
import 'package:quiz_app/utils/constants.dart';
import 'package:quiz_app/screens/quiz_result_screen.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/utils/theme_notifier.dart';

class QuestionScreen extends StatefulWidget {
  final String category;
  final String difficulty;
  const QuestionScreen({super.key, required this.category, required this.difficulty});

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late Color _categoryColor;
  int _timer = 10;
  Timer? _timerObj;
  final List<String?> _userAnswers = [];
  final QuizService _quizService = QuizService();
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _isAnswered = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _categoryColor = AppColors.categoryColors[widget.category] ?? Colors.indigo;
    _loadQuestions();
  }
  void _startTimer() {
    _timerObj?.cancel();
    setState(() => _timer = 10);
    _timerObj = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timer > 0) {
        setState(() => _timer--);
      } else {
        timer.cancel();
        _autoNext();
      }
    });
  }

  void _autoNext() {
    if (!_isAnswered) {
      _userAnswers.add(null);
    }
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _isAnswered = false;
      });
      _startTimer();
    } else {
      _timerObj?.cancel();
      _submitQuiz();
    }
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    final questions = await _quizService.fetchQuestions(
      category: widget.category,
      difficulty: widget.difficulty,
    );
    setState(() {
      _questions = questions;
      _userAnswers.clear();
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswer = null;
      _isAnswered = false;
      _isLoading = false;
    });
    if (questions.isNotEmpty) {
      _startTimer();
    }
  }

  void _selectAnswer(String answer) {
    if (_isAnswered) return;
    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      final correct = _questions[_currentQuestionIndex].correctAnswer;
      if (answer == correct) _score++;
      _userAnswers.add(answer);
    });
    _timerObj?.cancel();
    // Wait a short moment to show feedback, then auto-advance
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _isAnswered = false;
      });
      _startTimer();
    } else {
      _timerObj?.cancel();
      _submitQuiz();
    }
  }

  Future<void> _submitQuiz() async {
    final supabase = SupabaseService();
    final user = supabase.currentUser;
    if (user == null) {
      // ignore: avoid_print
      print('No user found in _submitQuiz');
      return;
    }
    final List<Map<String, dynamic>> questionsForDb = _questions.asMap().entries.map((entry) {
      final idx = entry.key;
      final q = entry.value;
      return {
        'question': q.question,
        'options': q.options,
        'correctAnswer': q.correctAnswer,
        'userAnswer': _userAnswers.length > idx ? _userAnswers[idx] : null,
      };
    }).toList();
    final quizData = {
      'created_by': user.id,
      'category': widget.category,
      'difficulty': widget.difficulty,
      'score': _score,
      'totalQuestions': _questions.length,
      'questions': questionsForDb,
      'created_at': DateTime.now().toIso8601String(),
      'title': '${widget.category} - ${widget.difficulty}',
    };
    // ignore: avoid_print
    print('Attempting to insert quiz: user.id=${user.id}, quizData=$quizData');
    try {
      final response = await supabase.client.from('quizzes').insert(quizData);
      // ignore: avoid_print
      print('Quiz insert response: $response');
    } catch (e) {
      // ignore: avoid_print
      print('Quiz insert error: $e');
    }
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(
        '/quiz_result',
        arguments: {
          'score': _score,
          'totalQuestions': _questions.length,
          'category': widget.category,
          'difficulty': widget.difficulty,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('No questions found.')),
      );
    }
    final q = _questions[_currentQuestionIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} - ${widget.difficulty[0].toUpperCase()}${widget.difficulty.substring(1)}'),
        backgroundColor: _categoryColor,
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () {
                  final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
                  themeNotifier.toggleTheme();
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [_categoryColor.withOpacity(0.8), Colors.black87]
                : [_categoryColor.withOpacity(0.7), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _questions.length,
                backgroundColor: Colors.grey[300],
                color: _categoryColor,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 20, color: Colors.red),
                      const SizedBox(width: 4),
                      Text('$_timer s', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                q.question,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ...q.options.map((option) {
                final isSelected = _selectedAnswer == option;
                final isCorrect = _isAnswered && option == q.correctAnswer;
                final isWrong = _isAnswered && isSelected && option != q.correctAnswer;
                Color? color;
                if (isCorrect) color = Colors.green;
                else if (isWrong) color = Colors.red;
                else if (isSelected) color = Colors.blue[200];
                return Card(
                  color: color,
                  child: ListTile(
                    title: Text(option),
                    onTap: !_isAnswered ? () => _selectAnswer(option) : null,
                  ),
                );
              }),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    _timerObj?.cancel();
    super.dispose();
  }
  // ...existing code...
}