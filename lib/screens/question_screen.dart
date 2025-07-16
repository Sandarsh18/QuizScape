// lib/screens/question_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quiz_app/models/question.dart';
import 'package:quiz_app/screens/result_screen.dart';
import 'package:quiz_app/services/quiz_service.dart';

class QuestionScreen extends StatefulWidget {
  final String category;
  const QuestionScreen({super.key, required this.category});

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  // Track hovered option for interactive UI
  String? _hoveredOption;
  final PageController _pageController = PageController();
  final QuizService _quizService = QuizService();
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _isAnswered = false;
  int _timer = 10;
  Timer? _timerObj;
  late final ValueNotifier<int> _timerNotifier;
  @override
  void initState() {
    super.initState();
    _timerNotifier = ValueNotifier<int>(_timer);
    _loadQuestions();
  }

  // Removed duplicate initState

  Future<void> _loadQuestions() async {
    final allQuestions = await _quizService.getQuestionsForCategory(widget.category);
    setState(() {
      _questions = _quizService.getRandomQuestions(allQuestions, 10);
      _startTimer();
    });
  }

  void _startTimer() {
    _timerObj?.cancel();
    _timer = 10;
    _timerNotifier.value = _timer;
    _timerObj = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timer > 0 && !_isAnswered) {
        _timer--;
        _timerNotifier.value = _timer;
        if (_timer == 0) {
          _autoAnswer();
        }
      }
    });
  }

  void _autoAnswer() {
    setState(() {
      _isAnswered = true;
      _selectedAnswer = null;
    });
    _timerObj?.cancel();
    Future.delayed(const Duration(seconds: 1), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          _currentQuestionIndex++;
          _isAnswered = false;
          _selectedAnswer = null;
        });
        _startTimer();
      });
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            score: _score,
            totalQuestions: _questions.length,
            category: widget.category,
          ),
        ),
      );
    }
  }

  void _answerQuestion(String answer) {
    setState(() {
      _isAnswered = true;
      _selectedAnswer = answer;
      if (answer == _questions[_currentQuestionIndex].correctAnswer) {
        _score++;
      }
    });
    _timerObj?.cancel();
    Future.delayed(const Duration(seconds: 1), () {
      _nextQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _questions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Progress bar for questions attempted
                      if (_questions.isNotEmpty)
                        Column(
                          children: [
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 0,
                                end: (_currentQuestionIndex + (_isAnswered ? 1 : 0)) / _questions.length,
                              ),
                              duration: Duration(milliseconds: 500),
                              builder: (context, value, child) => LinearProgressIndicator(
                                value: value,
                                minHeight: 8,
                                backgroundColor: Colors.white,
                                color: Colors.purpleAccent,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Progress: ${_currentQuestionIndex + (_isAnswered ? 1 : 0)}/${_questions.length}',
                              style: TextStyle(fontSize: 14, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      SizedBox(height: 12),
                      // Progress bar for time left
                      ValueListenableBuilder<int>(
                        valueListenable: _timerNotifier,
                        builder: (context, value, child) {
                          return Column(
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: value / 10),
                                duration: Duration(milliseconds: 500),
                                builder: (context, val, child) => LinearProgressIndicator(
                                  value: val,
                                  minHeight: 8,
                                  backgroundColor: Colors.white,
                                  color: value <= 3 ? Colors.redAccent : Colors.greenAccent,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Time left: ${value}s',
                                style: TextStyle(
                                  color: value <= 3 ? Colors.redAccent : Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  shadows: [Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(1,1))],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _questions.length,
                          itemBuilder: (context, index) {
                            final question = _questions[index];
                            return AnimatedSwitcher(
                              duration: Duration(milliseconds: 500),
                              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                              child: Column(
                                key: ValueKey(index),
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Question ${index + 1}/${_questions.length}',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.yellowAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      shadows: [Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(1,1))],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    question.question,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                      shadows: [Shadow(blurRadius: 6, color: Colors.black38, offset: Offset(2,2))],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 40),
                                  ...question.options.map((option) {
                                    final isSelected = _selectedAnswer == option && index == _currentQuestionIndex;
                                    final isCorrect = option == question.correctAnswer && _isAnswered && index == _currentQuestionIndex;
                                    final isWrong = isSelected && !isCorrect && _isAnswered && index == _currentQuestionIndex;
                                    final isHovered = _hoveredOption == option && index == _currentQuestionIndex;
                                    Color bgColor;
                                    if (isCorrect) {
                                      bgColor = Colors.greenAccent;
                                    } else if (isWrong) {
                                      bgColor = Colors.redAccent;
                                    } else if (isSelected) {
                                      bgColor = Colors.blueAccent;
                                    } else if (isHovered) {
                                      bgColor = Colors.orangeAccent;
                                    } else {
                                      bgColor = Colors.white;
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: MouseRegion(
                                        onEnter: (_) {
                                          setState(() {
                                            _hoveredOption = option;
                                          });
                                        },
                                        onExit: (_) {
                                          setState(() {
                                            _hoveredOption = null;
                                          });
                                        },
                                        child: Card(
                                          elevation: isSelected || isHovered ? 12 : 4,
                                          color: bgColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                          shadowColor: isSelected || isHovered ? Colors.blueAccent : Colors.black26,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(18),
                                            onTap: _isAnswered || index != _currentQuestionIndex ? null : () => _answerQuestion(option),
                                            child: AnimatedContainer(
                                              duration: Duration(milliseconds: 300),
                                              curve: Curves.easeInOut,
                                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                              child: AnimatedDefaultTextStyle(
                                                duration: Duration(milliseconds: 300),
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: isSelected || isHovered ? FontWeight.bold : FontWeight.normal,
                                                  color: isCorrect
                                                      ? Colors.white
                                                      : isWrong
                                                          ? Colors.white
                                                          : isSelected || isHovered
                                                              ? Colors.white
                                                              : Colors.black,
                                                ),
                                                child: Center(child: Text(option)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
  @override
  void dispose() {
    _timerObj?.cancel();
    _timerNotifier.dispose();
    super.dispose();
  }
}