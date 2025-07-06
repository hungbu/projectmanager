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
      
      print('🔍 getAllUsers response: $response');
      
      // Handle different response formats
      List<dynamic> data;
      if (response is Map<String, dynamic>) {
        // Check if response is wrapped in a data field
        if (response.containsKey('data')) {
          data = response['data'] as List<dynamic>;
        } else {
          throw Exception('Unexpected response format: missing data field');
        }
      } else if (response is List<dynamic>) {
        // Direct array response from Laravel API
        data = response;
      } else {
        throw Exception('Unexpected response format: ${response.runtimeType}');
      }
      
      print('🔍 Users data to parse: $data');
      
      final users = <User>[];
      for (int i = 0; i < data.length; i++) {
        try {
          final userData = data[i];
          if (userData is Map<String, dynamic>) {
            final user = User.fromJson(userData);
            users.add(user);
          } else {
            print('⚠️ Skipping invalid user data at index $i: $userData');
          }
        } catch (e) {
          print('❌ Error parsing user at index $i: $e');
          print('❌ User data: ${data[i]}');
        }
      }
      
      print('✅ Successfully parsed ${users.length} users');
      return users;
    } catch (e) {
      print('❌ Error loading users: $e');
      throw Exception('Error loading users: $e');
    }
  }

  // Create new user
  Future<User> createUser({
    required String email,
    required String fullName,
    required String password,
    required String passwordConfirmation,
    required UserRole role,
  }) async {
    try {
      print('🔍 Creating user with data: {email: $email, name: $fullName, role: ${role.name}}');
      
      final response = await ApiService.post(
        ApiEndpoints.users,
        {
          'email': email,
          'name': fullName,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'role': role.name,
        },
      );
      
      print('🔍 createUser response: $response');
      
      // Handle different response formats
      Map<String, dynamic> userData;
      if (response is Map<String, dynamic>) {
        // Check if response has a 'user' field (Laravel API format)
        if (response.containsKey('user')) {
          userData = response['user'] as Map<String, dynamic>;
        } else {
          // Direct user data
          userData = response;
        }
      } else {
        throw Exception('Unexpected response format: ${response.runtimeType}');
      }
      
      print('🔍 User data to parse: $userData');
      
      final user = User.fromJson(userData);
      print('✅ User created successfully: ${user.fullName} (${user.email})');
      return user;
    } catch (e) {
      print('❌ Error creating user: $e');
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
      if (fullName != null) updateData['name'] = fullName;
      if (role != null) updateData['role'] = role.name;
      if (isActive != null) updateData['is_active'] = isActive;

      print('🔍 Updating user $userId with data: $updateData');

      final response = await ApiService.put(
        '${ApiEndpoints.users}/$userId',
        updateData,
      );

      print('🔍 updateUser response: $response');

      // Handle different response formats
      Map<String, dynamic> userData;
      if (response is Map<String, dynamic>) {
        // Check if response has a 'user' field (Laravel API format)
        if (response.containsKey('user')) {
          userData = response['user'] as Map<String, dynamic>;
        } else {
          // Direct user data
          userData = response;
        }
      } else {
        throw Exception('Unexpected response format: ${response.runtimeType}');
      }

      print('🔍 User data to parse: $userData');

      final user = User.fromJson(userData);
      print('✅ User updated successfully: ${user.fullName} (${user.email})');
      return user;
    } catch (e) {
      print('❌ Error updating user: $e');
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
      print('🔍 Toggling user $userId status to: $isActive');

      final response = await ApiService.put(
        '${ApiEndpoints.users}/$userId',
        {'is_active': isActive},
      );

      print('🔍 toggleUserStatus response: $response');

      // Handle different response formats
      Map<String, dynamic> userData;
      if (response is Map<String, dynamic>) {
        // Check if response has a 'user' field (Laravel API format)
        if (response.containsKey('user')) {
          userData = response['user'] as Map<String, dynamic>;
        } else {
          // Direct user data
          userData = response;
        }
      } else {
        throw Exception('Unexpected response format: ${response.runtimeType}');
      }

      print('🔍 User data to parse: $userData');

      final user = User.fromJson(userData);
      print('✅ User status updated successfully: ${user.fullName} (${user.email}) - Active: ${user.isActive}');
      return user;
    } catch (e) {
      print('❌ Error updating user status: $e');
      throw Exception('Error updating user status: $e');
    }
  }
}

// Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
}); 