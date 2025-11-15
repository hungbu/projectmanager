import 'package:flutter/foundation.dart';

import '../services/api_service.dart';
import '../constants/api_endpoints.dart';

class ManualTokenTest {
  // Manually set a token for testing
  static void setTestToken(String token) {
    if (kDebugMode) {
      ApiService.setAuthToken(token);
    }
  }

  // Test login and token saving
  static Future<void> testLoginAndToken() async {
    if (kDebugMode) {

      try {
        // Test login
        final response = await ApiService.post(
          ApiEndpoints.login,
          {
            'email': 'test@example.com',
            'password': 'password123',
          },
        );

        // Test user endpoint with new token
        await Future.delayed(const Duration(seconds: 1));
        final userResponse = await ApiService.get(ApiEndpoints.user);

      } catch (e) {

      }
    }
  }

  // Test token format
  static void testTokenFormat(String token) {
    if (kDebugMode) {

      // Set token and test
      ApiService.setAuthToken(token);

    }
  }

  // Test all endpoints with current token
  static Future<void> testAllEndpointsWithCurrentToken() async {
    if (kDebugMode) {

      final endpoints = [
        ApiEndpoints.user,
        ApiEndpoints.projects,
        ApiEndpoints.tasks,
      ];
      
      for (final endpoint in endpoints) {
        try {
          final response = await ApiService.get(endpoint);
        } catch (e) {

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

      } else {

      }
    }
  }
} 