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

      // Don't immediately clear token - let the auth service validate first
      // Only clear if this is a repeated 401 error or after validation
      _handleUnauthorizedError(context);
    }
  }
  
  // Handle unauthorized errors more carefully
  static void _handleUnauthorizedError(BuildContext? context) {
    // Don't immediately force logout - let the auth service handle validation
    // This prevents clearing valid tokens due to timing issues

    // Show message to user
    if (context != null) {
      NavigationService.showSnackBar(
        'Authentication error. Please try again.',
        isError: true,
      );
    } else {
      // Try to show message using current context
      NavigationService.showSnackBar(
        'Authentication error. Please try again.',
        isError: true,
      );
    }
  }
  
  // Force logout without API call (for 401 errors)
  static Future<void> _forceLogout() async {
    try {

      // Use auth provider if available
      if (_container != null) {

        final authNotifier = _container!.read(authStateProvider.notifier);
        await authNotifier.forceLogout();
        
        // The router will automatically redirect to login when auth state changes

      } else {

        // Fallback to direct auth service
        await AuthService.clearUserData();
        
        // Try to navigate to login as fallback
        final context = NavigationService.currentContext;
        if (context != null) {
          NavigationService.redirectToLogin(context);

        } else {

        }
      }

    } catch (e) {

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