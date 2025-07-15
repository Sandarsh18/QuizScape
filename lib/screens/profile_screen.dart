// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <-- ADD THIS IMPORT STATEMENT
import 'package:quiz_app/models/user.dart';
import 'package:quiz_app/screens/login_screen.dart';
import 'package:quiz_app/services/auth_service.dart';
import 'package:quiz_app/services/storage_service.dart';
import 'package:quiz_app/widgets/gradient_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _storageService.getUser();
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          )
        ],
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: _user == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
                children: [
                  Center(
                    child: Text(
                      'Welcome, ${_user!.username}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text('Quiz History', style: TextStyle(color: Colors.white, fontSize: 20)),
                  const SizedBox(height: 10),
                  _user!.quizHistory.isEmpty
                      ? const Text('No quizzes taken yet.', style: TextStyle(color: Colors.white70))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _user!.quizHistory.length,
                          itemBuilder: (context, index) {
                            final result = _user!.quizHistory[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                title: Text(result.category),
                                subtitle: Text(DateFormat.yMMMd().format(result.date)), // This line now works
                                trailing: Text(
                                  '${result.score}/${result.totalQuestions}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
      ),
    );
  }
}