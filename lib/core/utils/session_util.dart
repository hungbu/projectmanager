import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';

class SessionUtil {
  // Print detailed session information
  static Future<void> printSessionInfo() async {
    print('🔍 === SESSION INFORMATION ===');
    
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    final authToken = prefs.getString('auth_token');
    
    print('📱 Stored User Data: ${userData != null ? 'Yes' : 'No'}');
    print('🔑 Stored Auth Token: ${authToken != null ? 'Yes' : 'No'}');
    
    if (authToken != null) {
      print('🔑 Token Preview: ${authToken.substring(0, 20)}...');
    }
    
    if (userData != null) {
      try {
        final userMap = json.decode(userData) as Map<String, dynamic>;
        print('👤 User Name: ${userMap['name']}');
        print('📧 User Email: ${userMap['email']}');
        print('🆔 User ID: ${userMap['id']}');
      } catch (e) {
        print('❌ Error parsing user data: $e');
      }
    }
    
    // Check current auth state
    final hasStoredSession = await AuthService.hasStoredSession();
    final isAuthenticated = AuthService.isAuthenticated;
    final currentUser = AuthService.currentUser;
    
    print('💾 Has Stored Session: $hasStoredSession');
    print('✅ Is Authenticated: $isAuthenticated');
    print('👤 Current User: ${currentUser?.fullName ?? 'None'}');
    
    print('🔍 === END SESSION INFO ===');
  }
  
  // Test session validation
  static Future<void> testSessionValidation() async {
    print('🧪 === TESTING SESSION VALIDATION ===');
    
    try {
      // Check if we have stored session
      final hasStoredSession = await AuthService.hasStoredSession();
      print('📱 Has stored session: $hasStoredSession');
      
      if (hasStoredSession) {
        // Try to validate session
        print('🔄 Validating session with server...');
        final user = await AuthService.getCurrentUser();
        
        if (user != null) {
          print('✅ Session validation successful');
          print('👤 User: ${user.fullName} (${user.email})');
        } else {
          print('❌ Session validation failed');
        }
      } else {
        print('ℹ️ No stored session to validate');
      }
    } catch (e) {
      print('❌ Session validation error: $e');
    }
    
    print('🧪 === END SESSION VALIDATION TEST ===');
  }
  
  // Clear session data
  static Future<void> clearSessionData() async {
    print('🗑️ === CLEARING SESSION DATA ===');
    
    try {
      await AuthService.clearUserData();
      print('✅ Session data cleared successfully');
    } catch (e) {
      print('❌ Error clearing session data: $e');
    }
    
    print('🗑️ === END CLEAR SESSION DATA ===');
  }
  
  // Check session status
  static Future<Map<String, dynamic>> getSessionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    final authToken = prefs.getString('auth_token');
    final hasStoredSession = await AuthService.hasStoredSession();
    final isAuthenticated = AuthService.isAuthenticated;
    final currentUser = AuthService.currentUser;
    
    return {
      'has_user_data': userData != null,
      'has_auth_token': authToken != null,
      'has_stored_session': hasStoredSession,
      'is_authenticated': isAuthenticated,
      'current_user': currentUser?.fullName,
      'user_email': currentUser?.email,
      'user_id': currentUser?.id,
    };
  }
} 