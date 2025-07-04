import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/navigation_service.dart';

class LogoutUtil {
  // Test logout functionality
  static Future<void> testLogout(BuildContext context) async {
    print('🧪 === TESTING LOGOUT FUNCTIONALITY ===');
    
    try {
      // Check current auth state
      final isAuthenticated = AuthService.isAuthenticated;
      final currentUser = AuthService.currentUser;
      
      print('🔍 Current Auth State:');
      print('  - Is Authenticated: $isAuthenticated');
      print('  - Current User: ${currentUser?.name ?? 'None'}');
      
      if (isAuthenticated) {
        print('🔄 Performing logout...');
        await AuthService.logout();
        
        print('✅ Logout completed');
        print('  - Is Authenticated: ${AuthService.isAuthenticated}');
        print('  - Current User: ${AuthService.currentUser?.name ?? 'None'}');
        
        // Show success message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logout test completed successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        print('ℹ️ No user logged in to logout');
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No user logged in to logout'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Logout test error: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout test failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    print('🧪 === END LOGOUT TEST ===');
  }
  
  // Force logout (for testing)
  static Future<void> forceLogout(BuildContext context) async {
    print('🚨 === FORCE LOGOUT ===');
    
    try {
      await AuthService.clearUserData();
      
      print('✅ Force logout completed');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Force logout completed'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to login
        NavigationService.redirectToLogin(context);
      }
    } catch (e) {
      print('❌ Force logout error: $e');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Force logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    print('🚨 === END FORCE LOGOUT ===');
  }
  
  // Check logout status
  static Future<Map<String, dynamic>> getLogoutStatus() async {
    final isAuthenticated = AuthService.isAuthenticated;
    final currentUser = AuthService.currentUser;
    final hasStoredSession = await AuthService.hasStoredSession();
    
    return {
      'is_authenticated': isAuthenticated,
      'current_user': currentUser?.name,
      'user_email': currentUser?.email,
      'has_stored_session': hasStoredSession,
    };
  }
} 