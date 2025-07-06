import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../domain/entities/user.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../../core/services/permission_service.dart';

class UserRepository {
  // Get all users
  Future<List<User>> getAllUsers() async {
    try {
      final response = await ApiService.get(ApiEndpoints.users);
      final List<dynamic> data = response['data'] ?? response;
      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error loading users: $e');
    }
  }

  // Create new user
  Future<User> createUser({
    required String email,
    required String fullName,
    required String password,
    required UserRole role,
  }) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.users,
        {
          'email': email,
          'full_name': fullName,
          'password': password,
          'role': role.name,
        },
      );
      
      return User.fromJson(response);
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  // Update user
  Future<User> updateUser({
    required String userId,
    String? email,
    String? fullName,
    UserRole? role,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (email != null) updateData['email'] = email;
      if (fullName != null) updateData['full_name'] = fullName;
      if (role != null) updateData['role'] = role.name;
      if (isActive != null) updateData['is_active'] = isActive;

      final response = await ApiService.put(
        '${ApiEndpoints.users}/$userId',
        updateData,
      );

      return User.fromJson(response);
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await ApiService.delete('${ApiEndpoints.users}/$userId');
    } catch (e) {
      throw Exception('Error deleting user: $e');
    }
  }

  // Deactivate/Activate user
  Future<User> toggleUserStatus(String userId, bool isActive) async {
    try {
      final response = await ApiService.put(
        '${ApiEndpoints.users}/$userId',
        {'is_active': isActive},
      );

      return User.fromJson(response);
    } catch (e) {
      throw Exception('Error updating user status: $e');
    }
  }
}

// Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
}); 