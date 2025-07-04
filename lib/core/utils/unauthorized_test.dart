import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/error_handler.dart';
import '../services/navigation_service.dart';

class UnauthorizedTest {
  // Test 401 error handling and navigation
  static void test401ErrorHandling(BuildContext context) {
    print('🧪 === TESTING 401 ERROR HANDLING ===');
    
    try {
      // Simulate a 401 error
      final error = Exception('Unauthorized. Please login again.');
      
      print('🚨 Simulating 401 error...');
      ErrorHandler.handleApiError(error, context: context);
      
      print('✅ 401 error test completed');
    } catch (e) {
      print('❌ 401 error test failed: $e');
    }
  }
  
  // Test navigation to login
  static void testNavigationToLogin(BuildContext context) {
    print('🧪 === TESTING NAVIGATION TO LOGIN ===');
    
    try {
      print('🔄 Testing navigation to login...');
      NavigationService.redirectToLogin(context);
      print('✅ Navigation test completed');
    } catch (e) {
      print('❌ Navigation test failed: $e');
    }
  }
  
  // Test context availability
  static void testContextAvailability() {
    print('🧪 === TESTING CONTEXT AVAILABILITY ===');
    
    final context = NavigationService.currentContext;
    if (context != null) {
      print('✅ Context is available');
    } else {
      print('❌ Context is not available');
    }
  }
  
  // Test router redirect functionality
  static void testRouterRedirect(BuildContext context) {
    print('🧪 === TESTING ROUTER REDIRECT ===');
    
    try {
      // Try to access GoRouter from context
      final goRouter = GoRouter.of(context);
      if (goRouter != null) {
        print('✅ GoRouter found in context');
        print('🔄 Testing router navigation...');
        goRouter.go('/login');
        print('✅ Router navigation test completed');
      } else {
        print('❌ GoRouter not found in context');
      }
    } catch (e) {
      print('❌ Router redirect test failed: $e');
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