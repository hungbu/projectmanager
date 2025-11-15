import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/error_handler.dart';
import '../services/navigation_service.dart';

class ApiErrorTest {
  // Test 401 error handling
  static void test401ErrorHandling(BuildContext context) {

    // Simulate a 401 error
    final error = Exception('Unauthorized. Please login again.');
    
    // Test the error handler
    ErrorHandler.handleApiError(error, context: context);

  }
  
  // Test API call that might return 401
  static Future<void> testApiCallWith401(BuildContext context) async {

    try {
      // This call might return 401 if token is invalid
      await ApiService.get('/api/test-endpoint');
    } catch (e) {

      // Check if it's a 401 error
      if (ErrorHandler.isUnauthorizedError(e)) {

        ErrorHandler.handleApiError(e, context: context);
      }
    }
  }
  
  // Show test options in a dialog
  static void showTestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Error Test'),
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
              testApiCallWith401(context);
            },
            child: const Text('Test API Call'),
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