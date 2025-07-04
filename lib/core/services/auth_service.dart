import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import '../constants/api_endpoints.dart';

class AuthService {
  static User? _currentUser;

  // Get current user
  static User? get currentUser => _currentUser;

  // Check if user is authenticated
  static bool get isAuthenticated => _currentUser != null;

  // Initialize auth service
  static Future<void> initialize() async {
    await ApiService.initialize();
    
    // Try to get stored user data
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      try {
        final userMap = json.decode(userData) as Map<String, dynamic>;
        _currentUser = User.fromJson(userMap);
      } catch (e) {
        // Clear invalid data
        await clearUserData();
      }
    }
  }

  // Login user
  static Future<User> login(String email, String password) async {
    final response = await ApiService.post(
      ApiEndpoints.login,
      {
        'email': email,
        'password': password,
      },
    );

    final user = User.fromJson(response['user']);
    final token = response['token'];

    // Save token and user data
    await ApiService.saveAuthToken(token);
    await _saveUserData(user);
    _currentUser = user;

    return user;
  }

  // Register user
  static Future<User> register(String name, String email, String password, String passwordConfirmation) async {
    final response = await ApiService.post(
      ApiEndpoints.register,
      {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    final user = User.fromJson(response['user']);
    final token = response['token'];

    // Save token and user data
    await ApiService.saveAuthToken(token);
    await _saveUserData(user);
    _currentUser = user;

    return user;
  }

  // Logout user
  static Future<void> logout() async {
    try {
      await ApiService.post(ApiEndpoints.logout, {});
    } catch (e) {
      // Even if logout fails on server, clear local data
    }

    await clearUserData();
  }

  // Get current user from server
  static Future<User?> getCurrentUser() async {
    try {
      final response = await ApiService.get(ApiEndpoints.user);
      final user = User.fromJson(response);
      await _saveUserData(user);
      _currentUser = user;
      return user;
    } catch (e) {
      await clearUserData();
      return null;
    }
  }

  // Save user data to storage
  static Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', user.toJsonString());
  }

  // Clear user data from storage
  static Future<void> clearUserData() async {
    _currentUser = null;
    await ApiService.clearAuthToken();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }
}

// User model
class User {
  final int id;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String toJsonString() {
    return toJson().toString();
  }
} 