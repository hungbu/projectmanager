import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  static BuildContext? _currentContext;
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  // Set current context
  static void setCurrentContext(BuildContext context) {
    _currentContext = context;
  }
  
  // Get navigator key for global navigation
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
  
  // Navigate to login page and clear navigation stack
  static void redirectToLogin(BuildContext context) {
    try {
      print('🔄 Attempting to navigate to login page...');
      
      // Try to find GoRouter in the context
      final goRouter = GoRouter.of(context);
      if (goRouter != null) {
        goRouter.go('/login');
        print('✅ Navigation to login successful using GoRouter');
      } else {
        print('⚠️ GoRouter not found in context, trying fallback...');
        // Fallback: try to use navigator key
        try {
          _navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
          print('✅ Fallback navigation to login successful');
        } catch (e2) {
          print('❌ Fallback navigation also failed: $e2');
        }
      }
    } catch (e) {
      print('❌ Navigation to login failed: $e');
      // Final fallback: try to use navigator key
      try {
        _navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);
        print('✅ Final fallback navigation to login successful');
      } catch (e2) {
        print('❌ All navigation attempts failed: $e2');
      }
    }
  }
  
  // Navigate to dashboard
  static void redirectToDashboard(BuildContext context) {
    try {
      context.go('/dashboard');
    } catch (e) {
      print('❌ Navigation to dashboard failed: $e');
    }
  }
  
  // Get current context
  static BuildContext? get currentContext => _currentContext;
  
  // Show snackbar with message
  static void showSnackBar(String message, {bool isError = false}) {
    final context = currentContext;
    if (context != null) {
      try {
        // Try to find ScaffoldMessenger in the context
        final scaffoldMessenger = ScaffoldMessenger.maybeOf(context);
        if (scaffoldMessenger != null) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: isError ? Colors.red : Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          print('⚠️ No ScaffoldMessenger found in context');
        }
      } catch (e) {
        print('❌ Failed to show snackbar: $e');
      }
    } else {
      print('⚠️ No context available for snackbar');
    }
  }
} 