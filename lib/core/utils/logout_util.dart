import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/navigation_service.dart';

class LogoutUtil {
  // Test logout functionality
  static Future<void> testLogout(BuildContext context) async {

    try {
      // Check current auth state
      final isAuthenticated = AuthService.isAuthenticated;
      final currentUser = AuthService.currentUser;

      if (isAuthenticated) {

        await AuthService.logout();

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

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout test failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

  }
  
  // Force logout (for testing)
  static Future<void> forceLogout(BuildContext context) async {

    try {
      await AuthService.clearUserData();

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

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Force logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

  }
  
  // Check logout status
  static Future<Map<String, dynamic>> getLogoutStatus() async {
    final isAuthenticated = AuthService.isAuthenticated;
    final currentUser = AuthService.currentUser;
    final hasStoredSession = await AuthService.hasStoredSession();
    
    return {
      'is_authenticated': isAuthenticated,
      'current_user': currentUser?.fullName,
      'user_email': currentUser?.email,
      'has_stored_session': hasStoredSession,
    };
  }
} 