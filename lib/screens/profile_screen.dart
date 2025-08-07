// lib/screens/profile_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <-- ADD THIS IMPORT STATEMENT
import 'package:quiz_app/models/user.dart';
import 'package:quiz_app/screens/login_screen.dart';
import 'package:quiz_app/services/auth_service.dart';
import 'package:quiz_app/widgets/gradient_background.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/utils/theme_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  User? _user;
  bool _editing = false;
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  List<Map> _quizHistory = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await _authService.getCurrentUser();
    final quizHistory = await _authService.getQuizResultsForCurrentUser();
    setState(() {
      _user = user;
      _quizHistory = quizHistory;
      _fullNameController.text = user?.fullName ?? '';
      _emailController.text = user?.email ?? '';
    });
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;

    final prefs = await SharedPreferences.getInstance();
    // This logic assumes user data is stored as a JSON map in SharedPreferences.
    // For better architecture, this would ideally be handled inside AuthService.
    final usersDataString = prefs.getString('users') ?? '{}';
    final Map<String, dynamic> users = json.decode(usersDataString);

    final updatedUserData = {
      'username': _user!.username,
      'password': _user!.password,
      'fullName': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
    };
    users[_user!.username] = updatedUserData;
    await prefs.setString('users', json.encode(users));

    setState(() {
      _editing = false;
      _user = User(
        username: updatedUserData['username'] as String,
        password: updatedUserData['password'] as String,
        fullName: updatedUserData['fullName'],
        email: updatedUserData['email'],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Logout'),
                        onPressed: () async {
                          await _authService.logout();
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
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
        child: _user == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
                children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    margin: const EdgeInsets.only(bottom: 30),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.indigo,
                            child: Text(
                              (_user!.fullName?.isNotEmpty == true
                                  ? _user!.fullName![0]
                                  : _user!.username[0]
                              ).toUpperCase(),
                              style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _editing
                              ? Column(
                                  children: [
                                    TextField(
                                      controller: _fullNameController,
                                      decoration: const InputDecoration(labelText: 'Full Name'),
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      controller: _emailController,
                                      decoration: const InputDecoration(labelText: 'Email'),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: _saveProfile,
                                      child: const Text('Save'),
                                    ),
<<<<<<< HEAD
=======
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Confirm Account Deletion'),
                                              content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
                                              actions: <Widget>[
                                                TextButton(
                                                  child: const Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                TextButton(
                                                  child: const Text('Delete'),
                                                  onPressed: () async {
                                                    await _authService.deleteAccount();
                                                    Navigator.of(context).pushAndRemoveUntil(
                                                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                                                      (route) => false,
                                                    );
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Delete Account'),
                                    ),
>>>>>>> 2c2cba5 (added delete button)
                                  ],
                                )
                              : Column(
                                  children: [
                                    Text(
                                      'Welcome, ${_user!.fullName?.isNotEmpty == true ? _user!.fullName! : _user!.username}',
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).textTheme.headlineSmall?.color,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (_user!.email != null && _user!.email!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          _user!.email!,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).textTheme.bodySmall?.color,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: () => setState(() => _editing = true),
                                      child: const Text('Edit Profile'),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quiz History', style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.onPrimary,
                          )),
                          const SizedBox(height: 10),
                          _quizHistory.isEmpty
                              ? Text('No quizzes taken yet.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)))
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _quizHistory.length,
                                  itemBuilder: (context, index) {
                                    final result = _quizHistory[index];
                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 5),
                                      color: Theme.of(context).cardColor,
                                      child: ListTile(
                                        title: Text(result['category'], style: Theme.of(context).textTheme.bodyLarge),
                                        subtitle: Text(DateFormat.yMMMd().format(DateTime.parse(result['date'])), style: Theme.of(context).textTheme.bodySmall),
                                        trailing: Text(
                                          '${result['score']}/${result['totalQuestions']}',
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}