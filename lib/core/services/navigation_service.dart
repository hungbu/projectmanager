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

      // Try to find GoRouter in the context
      final goRouter = GoRouter.of(context);
      goRouter.go('/login');

    } catch (e) {

      // Final fallback: try to use navigator key
      try {
        _navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (route) => false);

      } catch (e2) {

      }
    }
  }
  
  // Navigate to workspace
  static void redirectToWorkspace(BuildContext context) {
    try {
      context.go('/workspace');
    } catch (e) {

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

        }
      } catch (e) {

      }
    } else {

    }
  }
} 