// lib/services/auth_service.dart
import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  final StorageService _storageService = StorageService();

  Future<User?> getCurrentUser() async {
    return await _storageService.getUser();
  }

  Future<bool> login(String username, String password) async {
    User? storedUser = await _storageService.getUser();
    if (storedUser != null && storedUser.username == username && storedUser.password == password) {
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String password) async {
    User? storedUser = await _storageService.getUser();
    if (storedUser != null && storedUser.username == username) {
      return false; // User already exists
    }
    User newUser = User(username: username, password: password);
    await _storageService.saveUser(newUser);
    return true;
  }

  Future<void> logout() async {
    await _storageService.clearUser();
  }
}