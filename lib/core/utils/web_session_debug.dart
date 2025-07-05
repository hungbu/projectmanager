import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';

class WebSessionDebug {
  // Debug web session storage
  static Future<void> debugWebSession() async {
    print('🔍 === WEB SESSION DEBUG ===');
    
    try {
      // Check if we're on web
      final isWeb = identical(0, 0.0);
      print('🌐 Platform: ${isWeb ? 'Web' : 'Mobile'}');
      
      // Check SharedPreferences availability
      final prefs = await SharedPreferences.getInstance();
      print('✅ SharedPreferences available');
      
      // Check current stored data
      final userData = prefs.getString('user_data');
      final authToken = prefs.getString('auth_token');
      
      print('📱 Stored Data:');
      print('  - User Data: ${userData != null ? 'Present' : 'Missing'}');
      print('  - Auth Token: ${authToken != null ? 'Present' : 'Missing'}');
      
      if (authToken != null) {
        print('  - Token Preview: ${authToken.substring(0, 20)}...');
      }
      
      // Check API Service state
      final apiToken = ApiService.getCurrentToken();
      print('🔑 API Service Token: ${apiToken != null ? 'Present' : 'Missing'}');
      
      if (apiToken != null) {
        print('  - API Token Preview: ${apiToken.substring(0, 20)}...');
      }
      
      // Check AuthService state
      final authServiceUser = AuthService.currentUser;
      final authServiceAuthenticated = AuthService.isAuthenticated;
      
      print('🔐 AuthService State:');
      print('  - Is Authenticated: $authServiceAuthenticated');
      print('  - Current User: ${authServiceUser?.name ?? 'None'}');
      
      // Test token persistence
      await _testTokenPersistence();
      
    } catch (e) {
      print('❌ Error during web session debug: $e');
    }
    
    print('🔍 === END WEB SESSION DEBUG ===');
  }
  
  // Test token persistence by saving and retrieving
  static Future<void> _testTokenPersistence() async {
    print('🧪 Testing token persistence...');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save a test token
      const testToken = 'test_token_123456789';
      await prefs.setString('test_token', testToken);
      print('✅ Test token saved');
      
      // Retrieve the test token
      final retrievedToken = prefs.getString('test_token');
      print('📱 Retrieved test token: ${retrievedToken == testToken ? 'Match' : 'Mismatch'}');
      
      // Clean up test token
      await prefs.remove('test_token');
      print('🗑️ Test token cleaned up');
      
    } catch (e) {
      print('❌ Token persistence test failed: $e');
    }
  }
  
  // Force refresh API service token from storage
  static Future<void> forceRefreshApiToken() async {
    print('🔄 Force refreshing API service token...');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('auth_token');
      
      if (storedToken != null) {
        // Manually set the token in API service
        ApiService.setAuthToken(storedToken);
        print('✅ API service token refreshed from storage');
        print('  - Token: ${storedToken.substring(0, 20)}...');
      } else {
        print('⚠️ No stored token found');
      }
      
    } catch (e) {
      print('❌ Error refreshing API token: $e');
    }
  }
  
  // Clear all session data
  static Future<void> clearAllSessionData() async {
    print('🗑️ Clearing all session data...');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Clear API service token
      ApiService.clearAuthToken();
      
      // Clear AuthService
      await AuthService.clearUserData();
      
      print('✅ All session data cleared');
      
    } catch (e) {
      print('❌ Error clearing session data: $e');
    }
  }
  
  // Test API call with current token
  static Future<void> testApiCall() async {
    print('🧪 Testing API call with current token...');
    
    try {
      final token = ApiService.getCurrentToken();
      print('🔑 Current API token: ${token != null ? 'Present' : 'Missing'}');
      
      if (token != null) {
        print('  - Token: ${token.substring(0, 20)}...');
        
        // Try to make a test API call
        try {
          final response = await ApiService.get('/user');
          print('✅ API call successful');
          print('  - Response: ${response.toString().substring(0, 100)}...');
        } catch (e) {
          print('❌ API call failed: $e');
        }
      } else {
        print('⚠️ No token available for API call');
      }
      
    } catch (e) {
      print('❌ Error testing API call: $e');
    }
  }
} 