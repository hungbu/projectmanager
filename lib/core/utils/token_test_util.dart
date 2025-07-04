import 'package:flutter/foundation.dart';

import '../services/api_service.dart';
import '../constants/api_endpoints.dart';

class TokenTestUtil {
  // Test if token is working
  static Future<void> testToken() async {
    if (kDebugMode) {
      print('🧪 Testing authentication token...');
      
      final token = ApiService.getCurrentToken();
      if (token == null) {
        print('❌ No token found');
        return;
      }
      
      print('🔑 Current token: ${token.substring(0, 20)}...');
      
      try {
        // Test user endpoint
        final response = await ApiService.get(ApiEndpoints.user);
        print('✅ Token test successful - User data: ${response['name']}');
      } catch (e) {
        print('❌ Token test failed: $e');
      }
    }
  }

  // Test specific endpoint with token
  static Future<void> testEndpoint(String endpoint) async {
    if (kDebugMode) {
      print('🧪 Testing endpoint: $endpoint');
      
      try {
        final response = await ApiService.get(endpoint);
        print('✅ Endpoint test successful');
        print('📊 Response keys: ${response.keys.toList()}');
      } catch (e) {
        print('❌ Endpoint test failed: $e');
      }
    }
  }

  // Print current token info
  static void printTokenInfo() {
    if (kDebugMode) {
      final token = ApiService.getCurrentToken();
      if (token != null) {
        print('🔑 Token Info:');
        print('   Length: ${token.length}');
        print('   Preview: ${token.substring(0, 20)}...');
        print('   Format: Bearer token');
      } else {
        print('⚠️ No token available');
      }
    }
  }

  // Test all protected endpoints
  static Future<void> testAllEndpoints() async {
    if (kDebugMode) {
      print('🧪 Testing all protected endpoints...');
      
      final endpoints = [
        ApiEndpoints.user,
        ApiEndpoints.projects,
        ApiEndpoints.tasks,
      ];
      
      for (final endpoint in endpoints) {
        await testEndpoint(endpoint);
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }
} 