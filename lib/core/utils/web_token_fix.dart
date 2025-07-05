import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';

class WebTokenFix {
  // Fix web token issues by ensuring proper initialization
  static Future<void> fixWebTokenIssues() async {
    print('🔧 === WEB TOKEN FIX ===');
    
    try {
      // Force refresh API service token from storage
      await ApiService.refreshTokenFromStorage();
      
      // Check if token is now available
      final token = ApiService.getCurrentToken();
      if (token != null) {
        print('✅ Token fix successful - token available');
        print('  - Token: ${token.substring(0, 20)}...');
      } else {
        print('❌ Token fix failed - no token available');
      }
      
    } catch (e) {
      print('❌ Error during web token fix: $e');
    }
    
    print('🔧 === END WEB TOKEN FIX ===');
  }
  
  // Ensure token is properly saved and loaded
  static Future<void> ensureTokenPersistence(String token) async {
    print('💾 Ensuring token persistence...');
    
    try {
      // Save token to API service
      await ApiService.saveAuthToken(token);
      
      // Verify token is saved
      final savedToken = ApiService.getCurrentToken();
      if (savedToken == token) {
        print('✅ Token persistence verified');
      } else {
        print('❌ Token persistence failed');
      }
      
      // Test storage directly
      final prefs = await SharedPreferences.getInstance();
      final storedToken = prefs.getString('auth_token');
      if (storedToken == token) {
        print('✅ Token stored in SharedPreferences');
      } else {
        print('❌ Token not found in SharedPreferences');
      }
      
    } catch (e) {
      print('❌ Error ensuring token persistence: $e');
    }
  }
  
  // Test API call with current token
  static Future<bool> testApiCallWithToken() async {
    print('🧪 Testing API call with current token...');
    
    try {
      final token = ApiService.getCurrentToken();
      if (token == null) {
        print('❌ No token available for API test');
        return false;
      }
      
      print('🔑 Testing with token: ${token.substring(0, 20)}...');
      
      // Try to make a test API call
      try {
        final response = await ApiService.get('/user');
        print('✅ API call successful');
        return true;
      } catch (e) {
        print('❌ API call failed: $e');
        return false;
      }
      
    } catch (e) {
      print('❌ Error testing API call: $e');
      return false;
    }
  }
  
  // Test API connection with detailed logging
  static Future<bool> testApiConnectionDetailed() async {
    print('🔍 === DETAILED API CONNECTION TEST ===');
    
    try {
      // Check token availability
      final token = ApiService.getCurrentToken();
      print('🔑 Token check: ${token != null ? 'Present' : 'Missing'}');
      
      if (token != null) {
        print('  - Token: ${token.substring(0, 20)}...');
      }
      
      // Test API connection
      final success = await ApiService.testApiConnection();
      
      if (success) {
        print('✅ API connection test passed');
      } else {
        print('❌ API connection test failed');
      }
      
      print('🔍 === END DETAILED API TEST ===');
      return success;
      
    } catch (e) {
      print('❌ Error during detailed API test: $e');
      print('🔍 === END DETAILED API TEST ===');
      return false;
    }
  }
  
  // Force reinitialize everything
  static Future<void> forceReinitialize() async {
    print('🔄 Force reinitializing auth system...');
    
    try {
      // Clear everything first
      await AuthService.clearUserData();
      
      // Reinitialize API service
      await ApiService.initialize();
      
      // Refresh token from storage
      await ApiService.refreshTokenFromStorage();
      
      print('✅ Force reinitialization complete');
      
    } catch (e) {
      print('❌ Error during force reinitialization: $e');
    }
  }
} 