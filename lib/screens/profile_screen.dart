import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:quiz_app/services/supabase_service.dart';
import 'package:quiz_app/widgets/gradient_background.dart';
import 'package:quiz_app/utils/theme_notifier.dart';
import 'package:quiz_app/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh profile/quiz history when returning to this screen
    _loadUserProfile();
  }
  final SupabaseService _supabaseService = SupabaseService();
  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _quizHistory = [];
  bool _editing = false;
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _supabaseService.currentUser;
    if (user == null) {
      setState(() {
        _userProfile = null;
        _quizHistory = [];
      });
      return;
    }
    final profile = await _supabaseService.client
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    final quizHistoryRaw = await _supabaseService.client
        .from('quizzes')
        .select()
        .eq('created_by', user.id)
        .order('created_at', ascending: false);
    // Robustly parse questions field
    final quizHistory = (quizHistoryRaw as List).map<Map<String, dynamic>>((q) {
      final map = Map<String, dynamic>.from(q);
      if (map['questions'] != null) {
        if (map['questions'] is String) {
          try {
            map['questions'] = List<Map<String, dynamic>>.from(
              (map['questions'] as String).isNotEmpty ? (map['questions'] is List ? map['questions'] : []) : []
            );
          } catch (_) {
            map['questions'] = [];
          }
        } else if (map['questions'] is List) {
          map['questions'] = List<Map<String, dynamic>>.from(map['questions']);
        }
      }
      return map;
    }).toList();
    // Debug print
    // ignore: avoid_print
    print('Loaded quiz history: '
        + quizHistory.map((q) => q['title'] ?? q['category'] ?? '').toList().toString());
    setState(() {
      _userProfile = profile;
      _quizHistory = quizHistory;
      _emailController.text = profile?['email'] ?? '';
    });
  }

  Future<void> _saveProfile() async {
    if (_userProfile == null) return;
    final user = _supabaseService.currentUser;
    if (user == null) return;
    final updates = {
      'fullName': _fullNameController.text.trim(),
      'email': _emailController.text.trim(),
    };
    await _supabaseService.client
        .from('users')
        .update(updates)
        .eq('id', user.id);
    setState(() {
      _editing = false;
      _userProfile = {...?_userProfile, ...updates};
    });
  }

  Future<void> _deleteAccount() async {
    final user = _supabaseService.currentUser;
    if (user == null) return;
    // Optionally: delete user row from users table
    await _supabaseService.client.from('users').delete().eq('id', user.id);
    // Optionally: delete user row from users table only, as SupabaseService does not have deleteAccount
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
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
            onPressed: () async {
              await _supabaseService.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
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
        child: _userProfile == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadUserProfile,
                child: ListView(
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
                                (() {
                                  final fullName = _userProfile?['fullName']?.toString();
                                  final username = _userProfile?['username']?.toString();
                                  final name = (fullName != null && fullName.isNotEmpty)
                                      ? fullName
                                      : (username ?? '');
                                  return name.isNotEmpty ? name[0].toUpperCase() : '';
                                })(),
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
                                                      Navigator.of(context).pop();
                                                      await _deleteAccount();
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
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Text(
                                        'Welcome, ${(() {
                                              final fullName = _userProfile?['fullName']?.toString();
                                              final username = _userProfile?['username']?.toString();
                                              return (fullName != null && fullName.isNotEmpty)
                                                  ? fullName
                                                  : (username ?? '');
                                            })()}',
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).textTheme.headlineSmall?.color,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      if (_userProfile?['email'] != null && _userProfile?['email'].toString().isNotEmpty == true)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            _userProfile?['email'] ?? '',
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
                                      final quiz = _quizHistory[index];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(vertical: 5),
                                        color: Theme.of(context).cardColor,
                                        child: ListTile(
                                          title: Text(
                                            quiz['title'] ?? quiz['category'] ?? '',
                                            style: Theme.of(context).textTheme.bodyLarge,
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              if (quiz['created_at'] != null)
                                                Text(
                                                  'Date: ' + DateFormat.yMMMd().format(DateTime.parse(quiz['created_at'])),
                                                  style: Theme.of(context).textTheme.bodySmall,
                                                ),
                                              if (quiz['difficulty'] != null)
                                                Text(
                                                  'Difficulty: ${quiz['difficulty']}',
                                                  style: Theme.of(context).textTheme.bodySmall,
                                                ),
                                              if (quiz['score'] != null && quiz['totalQuestions'] != null)
                                                Text(
                                                  'Score: ${quiz['score']} / ${quiz['totalQuestions']}',
                                                  style: Theme.of(context).textTheme.bodySmall,
                                                ),
                                              if (quiz['questions'] != null)
                                                Text('Tap to view answers', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue)),
                                            ],
                                          ),
                                          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.primary),
                                          onTap: quiz['questions'] != null
                                              ? () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      final List<dynamic> questions = quiz['questions'] is String
                                                          ? (quiz['questions'] != null ? List<Map<String, dynamic>>.from(
                                                              (quiz['questions'] as String).isNotEmpty ? (quiz['questions'] is List ? quiz['questions'] : []) : [])
                                                            : [])
                                                          : List<Map<String, dynamic>>.from(quiz['questions'] ?? []);
                                                      return AlertDialog(
                                                        title: Text('Quiz Answers'),
                                                        content: SizedBox(
                                                          width: double.maxFinite,
                                                          child: ListView.builder(
                                                            shrinkWrap: true,
                                                            itemCount: questions.length,
                                                            itemBuilder: (context, qIdx) {
                                                              final q = questions[qIdx];
                                                              return Padding(
                                                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text('Q${qIdx + 1}: ${q['question'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                                                    if (q['userAnswer'] != null)
                                                                      Text('Your answer: ${q['userAnswer']}', style: TextStyle(color: Colors.blue)),
                                                                    if (q['correctAnswer'] != null)
                                                                      Text('Correct answer: ${q['correctAnswer']}', style: TextStyle(color: Colors.green)),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.of(context).pop(),
                                                            child: const Text('Close'),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                }
                                              : null,
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
      ),
    );
  }
}