import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/error_handler.dart';
import '../services/navigation_service.dart';

class UnauthorizedTest {
  // Test 401 error handling and navigation
  static void test401ErrorHandling(BuildContext context) {

    try {
      // Simulate a 401 error
      final error = Exception('Unauthorized. Please login again.');

      ErrorHandler.handleApiError(error, context: context);

    } catch (e) {

    }
  }
  
  // Test navigation to login
  static void testNavigationToLogin(BuildContext context) {

    try {

      NavigationService.redirectToLogin(context);

    } catch (e) {

    }
  }
  
  // Test context availability
  static void testContextAvailability() {

    final context = NavigationService.currentContext;
    if (context != null) {

    } else {

    }
  }
  
  // Test router redirect functionality
  static void testRouterRedirect(BuildContext context) {

    try {
      // Try to access GoRouter from context
      final goRouter = GoRouter.of(context);
      if (goRouter != null) {

        goRouter.go('/login');

      } else {

      }
    } catch (e) {

    }
  }
  
  // Show test dialog
  static void showTestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('401 Error Test'),
        content: const Text('Choose a test to run:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              test401ErrorHandling(context);
            },
            child: const Text('Test 401 Handler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              testNavigationToLogin(context);
            },
            child: const Text('Test Navigation'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              testContextAvailability();
            },
            child: const Text('Test Context'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              testRouterRedirect(context);
            },
            child: const Text('Test Router'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
} 