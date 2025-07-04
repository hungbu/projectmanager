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
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    
    // Debug logging
    if (_authToken != null) {
      print('🔑 Auth token loaded: ${_authToken!.substring(0, 20)}...');
    } else {
      print('⚠️ No auth token found in storage');
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

  // Get auth headers
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
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers,
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
  static Future<Map<String, dynamic>> post(
    String endpoint, 
    Map<String, dynamic> data
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers,
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
  static Future<Map<String, dynamic>> put(
    String endpoint, 
    Map<String, dynamic> data
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers,
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
  static Future<Map<String, dynamic>> patch(
    String endpoint, 
    Map<String, dynamic> data
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers,
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
      final response = await http.delete(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _headers,
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
    
    // Handle 401 errors globally
    if (response.statusCode == 401) {
      print('🚨 401 Unauthorized detected in API call');
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