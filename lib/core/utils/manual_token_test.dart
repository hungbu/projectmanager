import 'package:flutter/foundation.dart';

import '../services/api_service.dart';
import '../constants/api_endpoints.dart';

class ManualTokenTest {
  // Manually set a token for testing
  static void setTestToken(String token) {
    if (kDebugMode) {
      print('🧪 Setting test token: ${token.substring(0, 20)}...');
      ApiService.setAuthToken(token);
    }
  }

  // Test login and token saving
  static Future<void> testLoginAndToken() async {
    if (kDebugMode) {
      print('🧪 Testing login and token saving...');
      
      try {
        // Test login
        final response = await ApiService.post(
          ApiEndpoints.login,
          {
            'email': 'test@example.com',
            'password': 'password123',
          },
        );
        
        print('✅ Login successful');
        print('🔑 Token received: ${response['token'].substring(0, 20)}...');
        
        // Test user endpoint with new token
        await Future.delayed(const Duration(seconds: 1));
        final userResponse = await ApiService.get(ApiEndpoints.user);
        print('✅ User endpoint test successful: ${userResponse['name']}');
        
      } catch (e) {
        print('❌ Login test failed: $e');
      }
    }
  }

  // Test token format
  static void testTokenFormat(String token) {
    if (kDebugMode) {
      print('🧪 Testing token format...');
      print('🔑 Token: $token');
      print('📏 Length: ${token.length}');
      print('🔍 Contains "|": ${token.contains('|')}');
      print('🔍 Contains ".": ${token.contains('.')}');
      
      // Set token and test
      ApiService.setAuthToken(token);
      
      print('✅ Token set for testing');
    }
  }

  // Test all endpoints with current token
  static Future<void> testAllEndpointsWithCurrentToken() async {
    if (kDebugMode) {
      print('🧪 Testing all endpoints with current token...');
      
      final endpoints = [
        ApiEndpoints.user,
        ApiEndpoints.projects,
        ApiEndpoints.tasks,
      ];
      
      for (final endpoint in endpoints) {
        try {
          final response = await ApiService.get(endpoint);
          print('✅ $endpoint: Success (${response.length} items)');
        } catch (e) {
          print('❌ $endpoint: Failed - $e');
        }
        
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  // Print detailed token information
  static void printDetailedTokenInfo() {
    if (kDebugMode) {
      final token = ApiService.getCurrentToken();
      
      if (token != null) {
        print('🔑 Detailed Token Info:');
        print('   Full Token: $token');
        print('   Length: ${token.length}');
        print('   First 20 chars: ${token.substring(0, 20)}');
        print('   Last 20 chars: ${token.substring(token.length - 20)}');
        print('   Contains "|": ${token.contains('|')}');
        print('   Contains ".": ${token.contains('.')}');
        print('   Authorization Header: Bearer $token');
      } else {
        print('⚠️ No token available');
      }
    }
  }
} 