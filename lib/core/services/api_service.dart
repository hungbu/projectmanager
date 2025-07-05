import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_endpoints.dart';
import 'error_handler.dart';

class ApiService {
  static const String _baseUrl = ApiEndpoints.baseUrl;
  static String? _authToken;

  // Initialize auth token from storage
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('auth_token');
      
      // Debug logging
      if (_authToken != null) {
        print('🔑 Auth token loaded: ${_authToken!.substring(0, 20)}...');
      } else {
        print('⚠️ No auth token found in storage');
      }
    } catch (e) {
      print('❌ Error initializing API service: $e');
      _authToken = null;
    }
  }

  // Save auth token to storage
  static Future<void> saveAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    
    // Debug logging
    print('🔑 Auth token saved: ${token.substring(0, 20)}...');
  }

  // Clear auth token from storage
  static Future<void> clearAuthToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    print('🗑️ Auth token cleared');
  }

  // Set auth token manually (for testing)
  static void setAuthToken(String token) {
    _authToken = token;
    print('🔑 Auth token set manually: ${token.substring(0, 20)}...');
  }

  // Get current auth token (for debugging)
  static String? getCurrentToken() {
    return _authToken;
  }

  // Test if API is accessible with current token
  static Future<bool> testApiConnection() async {
    try {
      final headers = await getHeaders();
      print('🧪 Testing API connection...');
      print('  - Headers: ${headers.keys}');
      if (headers['Authorization'] != null) {
        print('  - Auth header: Bearer ${headers['Authorization']!.substring(7, 27)}...');
      }
      
      // Try a simple GET request to test connection
      final url = Uri.parse('$_baseUrl/user');
      print('  - Request URL: $url');
      print('  - Request headers: $headers');
      
      final response = await http.get(url, headers: headers);
      
      print('  - Response status: ${response.statusCode}');
      print('  - Response headers: ${response.headers}');
      print('  - Response body: ${response.body.substring(0, 200)}...');
      
      if (response.statusCode == 200) {
        print('✅ API connection test successful');
        return true;
      } else {
        print('❌ API connection test failed: ${response.statusCode}');
        print('  - Error response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ API connection test error: $e');
      return false;
    }
  }

  // Force refresh token from storage
  static Future<void> refreshTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('auth_token');
      
      if (_authToken != null) {
        print('🔄 Token refreshed from storage: ${_authToken!.substring(0, 20)}...');
      } else {
        print('⚠️ No token found in storage during refresh');
      }
    } catch (e) {
      print('❌ Error refreshing token from storage: $e');
      _authToken = null;
    }
  }

  // Get auth headers with token refresh
  static Future<Map<String, String>> getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest', // For Laravel CSRF protection
    };
    
    // If no token in memory, try to refresh from storage
    if (_authToken == null) {
      await refreshTokenFromStorage();
    }
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
      print('🔑 Adding Authorization header: Bearer ${_authToken!.substring(0, 20)}...');
    } else {
      print('⚠️ No auth token available for request');
    }
    
    return headers;
  }

  // Get auth headers (synchronous version for backward compatibility)
  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
      print('🔑 Adding Authorization header: Bearer ${_authToken!.substring(0, 20)}...');
    } else {
      print('⚠️ No auth token available for request');
    }
    
    return headers;
  }

  // Generic GET request
  static Future<dynamic> get(String endpoint) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic POST request
  static Future<dynamic> post(
    String endpoint, 
    Map<String, dynamic> data
  ) async {
    try {
      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic PUT request
  static Future<dynamic> put(
    String endpoint, 
    Map<String, dynamic> data
  ) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic PATCH request
  static Future<dynamic> patch(
    String endpoint, 
    Map<String, dynamic> data
  ) async {
    try {
      final headers = await getHeaders();
      final response = await http.patch(
        Uri.parse('$_baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Generic DELETE request
  static Future<void> delete(String endpoint) async {
    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl$endpoint'),
        headers: headers,
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _handleError(response);
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Handle API errors
  static Exception _handleError(http.Response response) {
    Exception exception;
    
    try {
      final errorData = json.decode(response.body);
      if (errorData['message'] != null) {
        exception = Exception(errorData['message']);
      } else {
        exception = _getExceptionByStatusCode(response.statusCode);
      }
    } catch (e) {
      // If we can't parse the error, use the status code
      exception = _getExceptionByStatusCode(response.statusCode);
    }
    
    // Handle 401 errors globally - but don't clear token immediately
    if (response.statusCode == 401) {
      print('🚨 401 Unauthorized detected in API call');
      print('🔍 Current token: ${_authToken != null ? 'Present' : 'Missing'}');
      if (_authToken != null) {
        print('  - Token: ${_authToken!.substring(0, 20)}...');
      }
      
      // Only clear token if it's definitely invalid (not just a timing issue)
      // Let the auth service handle token clearing after validation
      ErrorHandler.handleApiError(exception);
    }
    
    return exception;
  }
  
  // Get exception by status code
  static Exception _getExceptionByStatusCode(int statusCode) {
    switch (statusCode) {
      case 401:
        return Exception('Unauthorized. Please login again.');
      case 403:
        return Exception('Forbidden. You don\'t have permission to perform this action.');
      case 404:
        return Exception('Resource not found.');
      case 422:
        return Exception('Validation error. Please check your input.');
      case 500:
        return Exception('Server error. Please try again later.');
      default:
        return Exception('Request failed with status: $statusCode');
    }
  }
} 