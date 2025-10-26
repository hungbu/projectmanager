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
      goRouter.go('/login');
      print('✅ Navigation to login successful using GoRouter');
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
  
  // Navigate to workspace
  static void redirectToWorkspace(BuildContext context) {
    try {
      context.go('/workspace');
    } catch (e) {
      print('❌ Navigation to workspace failed: $e');
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