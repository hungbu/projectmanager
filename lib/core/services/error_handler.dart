import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';
import 'navigation_service.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

class ErrorHandler {
  static ProviderContainer? _container;
  
  // Set the provider container for accessing providers
  static void setContainer(ProviderContainer container) {
    _container = container;
  }
  
  // Handle API errors globally
  static void handleApiError(dynamic error, {BuildContext? context}) {
    if (error.toString().contains('401') || 
        error.toString().contains('Unauthorized') ||
        error.toString().contains('Please login again')) {
      
      print('🚨 401 Unauthorized detected - forcing logout');
      
      // Force logout
      _forceLogout();
      
      // Show message to user
      if (context != null) {
        NavigationService.showSnackBar(
          'Session expired. Please login again.',
          isError: true,
        );
      } else {
        // Try to show message using current context
        NavigationService.showSnackBar(
          'Session expired. Please login again.',
          isError: true,
        );
      }
    }
  }
  
  // Force logout without API call (for 401 errors)
  static Future<void> _forceLogout() async {
    try {
      print('🔄 Starting forced logout process...');
      
      // Use auth provider if available
      if (_container != null) {
        print('📱 Using auth provider for logout');
        final authNotifier = _container!.read(authStateProvider.notifier);
        await authNotifier.forceLogout();
        
        // The router will automatically redirect to login when auth state changes
        print('✅ Auth provider logout completed - router will handle navigation automatically');
      } else {
        print('📱 Using direct auth service for logout');
        // Fallback to direct auth service
        await AuthService.clearUserData();
        
        // Try to navigate to login as fallback
        final context = NavigationService.currentContext;
        if (context != null) {
          print('🔄 Navigating to login page (fallback)...');
          NavigationService.redirectToLogin(context);
          print('✅ Navigation to login completed');
        } else {
          print('⚠️ No context available for navigation');
        }
      }
      
      print('✅ Forced logout completed');
    } catch (e) {
      print('❌ Error during forced logout: $e');
    }
  }
  
  // Check if error is a 401 error
  static bool isUnauthorizedError(dynamic error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('401') || 
           errorString.contains('unauthorized') ||
           errorString.contains('please login again');
  }
} 