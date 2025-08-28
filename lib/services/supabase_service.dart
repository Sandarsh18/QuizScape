
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer';

/// SupabaseService provides Auth and CRUD for users and quizzes tables.
///
/// Supabase credentials are loaded from environment variables using flutter_dotenv in main.dart.
/// See .env.example for setup instructions. Do NOT hardcode credentials here.
class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  // 1. Create or insert user after sign up/sign in
  Future<void> createUser({required String id, required String username, required String email}) async {
    try {
      final response = await client.from('users').upsert({
        'id': id,
        'username': username,
        'email': email,
        'created_at': DateTime.now().toIso8601String(),
      });
      log('User upserted: $response');
    } catch (e) {
      log('Error inserting user: $e');
      rethrow;
    }
  }

  // 2. Fetch user by id
  Future<Map<String, dynamic>?> getUserById(String id) async {
    try {
      final response = await client.from('users').select().eq('id', id).single();
      log('Fetched user: $response');
      return response;
    } catch (e) {
      log('Error fetching user: $e');
      return null;
    }
  }

  // 3. Create quiz
  Future<void> createQuiz({
    required String title,
    required String category,
    required String difficulty,
    required List<Map<String, dynamic>> questions,
    required String createdBy,
  }) async {
    try {
      final response = await client.from('quizzes').insert({
        'title': title,
        'category': category,
        'difficulty': difficulty,
        'questions': questions,
        'created_by': createdBy,
        'created_at': DateTime.now().toIso8601String(),
      });
      log('Quiz created: $response');
    } catch (e) {
      log('Error creating quiz: $e');
      rethrow;
    }
  }

  // 4. Get all quizzes
  Future<List<Map<String, dynamic>>> getQuizzes() async {
    try {
      final response = await client.from('quizzes').select();
      log('Fetched quizzes: $response');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      log('Error fetching quizzes: $e');
      return [];
    }
  }

  // 5. Update quiz
  Future<void> updateQuiz({
    required String quizId,
    String? title,
    String? category,
    String? difficulty,
    List<Map<String, dynamic>>? questions,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (category != null) updateData['category'] = category;
      if (difficulty != null) updateData['difficulty'] = difficulty;
      if (questions != null) updateData['questions'] = questions;
      final response = await client.from('quizzes').update(updateData).eq('id', quizId);
      log('Quiz updated: $response');
    } catch (e) {
      log('Error updating quiz: $e');
      rethrow;
    }
  }

  // 6. Delete quiz
  Future<void> deleteQuiz(String quizId) async {
    try {
      final response = await client.from('quizzes').delete().eq('id', quizId);
      log('Quiz deleted: $response');
    } catch (e) {
      log('Error deleting quiz: $e');
      rethrow;
    }
  }

  // --- Auth Example Methods ---
  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final response = await client.auth.signUp(email: email, password: password);
      log('Sign up: $response');
      return response;
    } catch (e) {
      log('Sign up error: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(email: email, password: password);
      log('Sign in: $response');
      return response;
    } catch (e) {
      log('Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await client.auth.signOut();
      log('Signed out');
    } catch (e) {
      log('Sign out error: $e');
      rethrow;
    }
  }

  User? get currentUser => client.auth.currentUser;
  Session? get currentSession => client.auth.currentSession;
}

// --- RLS Policy Guidance ---
// To disable RLS temporarily (not recommended for production):
// alter table users disable row level security;
// alter table quizzes disable row level security;
//
// To enable RLS and allow authenticated users:
// Example policy for users table:
// create policy "Allow authenticated" on users for select using (auth.uid() = id);
// Example policy for quizzes table:
// create policy "Allow owner" on quizzes for all using (auth.uid() = created_by);
