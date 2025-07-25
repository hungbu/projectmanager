import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_endpoints.dart';
import 'error_handler.dart';

class ApiService {
  static const String _baseUrl = ApiEndpoints.baseUrl;
  static String? _authToken;
  static String? _csrfToken;

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
    print('🔑 Starting saveAuthToken process...');
    print('🔑 Token to save: ${token.substring(0, 20)}...');
    
    try {
      _authToken = token;
      print('✅ Token set in memory');
      
      final prefs = await SharedPreferences.getInstance();
      print('✅ SharedPreferences instance obtained');
      
      await prefs.setString('auth_token', token);
      print('✅ Token saved to SharedPreferences');
      
      // Debug logging
      print('🔑 Auth token saved: ${token.substring(0, 20)}...');
      
      // Verify token was saved correctly
      await Future.delayed(const Duration(milliseconds: 50));
      final savedToken = prefs.getString('auth_token');
      if (savedToken == token) {
        print('✅ Token verification successful');
      } else {
        print('❌ Token verification failed');
        print('  - Expected: ${token.substring(0, 20)}...');
        print('  - Got: ${savedToken?.substring(0, 20) ?? 'null'}...');
        
        // Try saving again
        await prefs.setString('auth_token', token);
        print('🔄 Retrying token save...');
        
        // Verify again
        final retryToken = prefs.getString('auth_token');
        if (retryToken == token) {
          print('✅ Token verification successful after retry');
        } else {
          print('❌ Token verification failed after retry');
        }
      }
    } catch (e) {
      print('❌ Error in saveAuthToken: $e');
      rethrow;
    }
  }

  // Clear auth token from storage
  static Future<void> clearAuthToken() async {
    _authToken = null;
    _csrfToken = null; // Also clear CSRF token
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    print('🗑️ Auth token and CSRF token cleared');
  }
  
  // Force clear and reinitialize token storage (for macOS issues)
  static Future<void> forceClearAndReinitialize() async {
    print('🔄 Force clearing and reinitializing token storage...');
    
    try {
      // Clear everything
      _authToken = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      
      // Wait a moment
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Try to reinitialize
      await initialize();
      
      print('✅ Force clear and reinitialize complete');
    } catch (e) {
      print('❌ Error during force clear and reinitialize: $e');
    }
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

  // Get CSRF token from server
  static Future<String?> getCsrfToken() async {
    if (_csrfToken != null) return _csrfToken;
    
    try {
      print('🔐 Fetching CSRF token from server...');
      final response = await http.get(
        Uri.parse('$_baseUrl${ApiEndpoints.csrfToken}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _csrfToken = data['token'];
        print('✅ CSRF token fetched: ${_csrfToken!.substring(0, 20)}...');
        return _csrfToken;
      } else {
        print('❌ Failed to fetch CSRF token: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching CSRF token: $e');
      return null;
    }
  }

  // Clear CSRF token
  static void clearCsrfToken() {
    _csrfToken = null;
    print('🗑️ CSRF token cleared');
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

  // Refresh token from storage
  static Future<void> refreshTokenFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('auth_token');
      
      if (_authToken != null) {
        print('🔑 Token refreshed from storage: ${_authToken!.substring(0, 20)}...');
      } else {
        print('⚠️ No token found in storage');
        
        // Additional debug info for macOS
        try {
          final allKeys = prefs.getKeys();
          print('🔍 Debug: All SharedPreferences keys: $allKeys');
          
          // Check if there are any auth-related keys
          final authKeys = allKeys.where((key) => key.contains('auth') || key.contains('token') || key.contains('user')).toList();
          print('🔍 Debug: Auth-related keys: $authKeys');
          
          for (final key in authKeys) {
            final value = prefs.getString(key);
            if (value != null) {
              print('🔍 Debug: Key "$key" has value: ${value.substring(0, 20)}...');
            }
          }
        } catch (e) {
          print('🔍 Debug: Error checking SharedPreferences keys: $e');
        }
      }
    } catch (e) {
      print('❌ Error refreshing token from storage: $e');
      _authToken = null;
    }
  }

  // Get auth headers with token refresh
  static Future<Map<String, String>> getHeaders({bool includeCsrf = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest', // For Laravel CSRF protection
    };
    
    // Add CSRF token if requested
    if (includeCsrf) {
      final csrfToken = await getCsrfToken();
      if (csrfToken != null) {
        headers['X-CSRF-TOKEN'] = csrfToken;
        print('🔐 Adding CSRF token to headers: ${csrfToken.substring(0, 20)}...');
      }
    }
    
    // Always try to refresh from storage on macOS to ensure token is available
    if (_authToken == null) {
      await refreshTokenFromStorage();
    }
    
    // Double-check token availability before making request
    if (_authToken == null) {
      // Try one more time with a small delay
      await Future.delayed(const Duration(milliseconds: 100));
      await refreshTokenFromStorage();
    }
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
      print('🔑 Adding Authorization header: Bearer ${_authToken!.substring(0, 20)}...');
    } else {
      print('⚠️ No auth token available for request');
      // Log additional debug info
      try {
        final prefs = await SharedPreferences.getInstance();
        final storedToken = prefs.getString('auth_token');
        print('🔍 Debug: Stored token in SharedPreferences: ${storedToken != null ? 'Present' : 'Missing'}');
        if (storedToken != null) {
          print('🔍 Debug: Stored token preview: ${storedToken.substring(0, 20)}...');
        }
      } catch (e) {
        print('🔍 Debug: Error checking SharedPreferences: $e');
      }
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
    Map<String, dynamic> data,
    {bool includeCsrf = true} // Default to true for POST requests
  ) async {
    try {
      final headers = await getHeaders(includeCsrf: includeCsrf);
      final url = '$_baseUrl$endpoint';
      final body = json.encode(data);
      
      print('🔍 POST request to: $url');
      print('🔍 Request headers: $headers');
      print('🔍 Request body: $body');
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('🔍 Response status: ${response.statusCode}');
      print('🔍 Response headers: ${response.headers}');
      print('🔍 Response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw _handleError(response);
      }
    } catch (e) {
      print('❌ POST request failed: $e');
      throw Exception('Network error: $e');
    }
  }

  // Generic PUT request
  static Future<dynamic> put(
    String endpoint, 
    Map<String, dynamic> data,
    {bool includeCsrf = true} // Default to true for PUT requests
  ) async {
    try {
      final headers = await getHeaders(includeCsrf: includeCsrf);
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
    Map<String, dynamic> data,
    {bool includeCsrf = true} // Default to true for PATCH requests
  ) async {
    try {
      final headers = await getHeaders(includeCsrf: includeCsrf);
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