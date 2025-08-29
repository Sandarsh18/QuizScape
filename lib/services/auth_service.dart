// lib/services/auth_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';
  static const String _quizResultsKey = 'quiz_results';

  Future<Map<String, dynamic>> _getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return {};
    return Map<String, dynamic>.from(jsonDecode(usersJson));
  }

  Future<void> _saveAllUsers(Map<String, dynamic> users) async {
// This file is deprecated. All authentication and user management is now handled by SupabaseService.
  }

  Future<String?> _getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey);
  }
  Future<void> _setCurrentUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, username);
  }
  Future<void> _clearCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  Future<User?> getCurrentUser() async {
    final users = await _getAllUsers();
    final username = await _getCurrentUsername();
    if (username != null && users.containsKey(username)) {
      final userMap = users[username] as Map<String, dynamic>;
      return User(
        username: userMap['username'] ?? '',
        password: userMap['password'] ?? '',
        fullName: userMap['fullName'],
        email: userMap['email'],
      );
    }
    return null;
  }

  Future<bool> login(String usernameOrEmail, String password) async {
    final users = await _getAllUsers();
    print('All users in prefs: $users');
    for (final entry in users.entries) {
      final user = entry.value as Map<String, dynamic>;
      if ((user['username'] == usernameOrEmail || user['email'] == usernameOrEmail) && user['password'] == password) {
        await _setCurrentUsername(user['username']);
        return true;
      }
    }
    return false;
  }

  Future<bool> register(String username, String password, {String? fullName, String? email}) async {
    final users = await _getAllUsers();
    if (users.containsKey(username)) {
      return false; // User already exists
    }
    final userMap = {
      'username': username,
      'password': password,
      'fullName': fullName,
      'email': email,
    };
    users[username] = userMap;
    await _saveAllUsers(users);
    await _setCurrentUsername(username);
    print('All users in prefs after register: $users');
    return true;
  }

  Future<void> logout() async {
    await _clearCurrentUsername();
  }

  Future<void> saveQuizResult({
    required String category,
    required int score,
    required int totalQuestions,
    required DateTime date,
  }) async {
    final user = await getCurrentUser();
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = prefs.getString(_quizResultsKey);
    List<dynamic> results = resultsJson != null ? jsonDecode(resultsJson) : [];
    results.add({
      'username': user.username,
      'category': category,
      'score': score,
      'totalQuestions': totalQuestions,
      'date': date.toIso8601String(),
    });
    await prefs.setString(_quizResultsKey, jsonEncode(results));
  }

  Future<List<Map<String, dynamic>>> getQuizResultsForCurrentUser() async {
    final user = await getCurrentUser();
    if (user == null) return [];
    final prefs = await SharedPreferences.getInstance();
    final resultsJson = prefs.getString(_quizResultsKey);
    List<dynamic> results = resultsJson != null ? jsonDecode(resultsJson) : [];
    return results
      .where((r) => r['username'] == user.username)
      .map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r))
      .toList();
  }

  Future<void> deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return;

    final Map<String, dynamic> users = jsonDecode(usersJson);
    final username = await _getCurrentUsername();
    if (username != null && users.containsKey(username)) {
      users.remove(username);
      await _saveAllUsers(users);
      await _clearCurrentUsername();
      await prefs.remove(_quizResultsKey); 
    }
  }

}