import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_service.dart';
import '../constants/api_endpoints.dart';
import '../../features/auth/domain/entities/user.dart';

class AuthService {
  static User? _currentUser;

  // Get current user
  static User? get currentUser => _currentUser;

  // Check if user is authenticated
  static bool get isAuthenticated => _currentUser != null;
  
  // Check if we have stored session data (without validation)
  static Future<bool> hasStoredSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    final authToken = prefs.getString('auth_token');
    return userData != null && authToken != null;
  }

  // Preload CSRF token for authentication
  static Future<void> preloadCsrfToken() async {
    try {

      await ApiService.getCsrfToken();

    } catch (e) {

      // Continue anyway - some servers might not require CSRF for API endpoints
    }
  }

  // Get current user from server (getme endpoint)
  static Future<User?> getMe() async {
    try {
      final response = await ApiService.get(ApiEndpoints.user);

      // Handle different response formats
      Map<String, dynamic> userData;
      if (response is Map<String, dynamic>) {
        // Check if response is wrapped in a data field
        if (response.containsKey('data')) {
          userData = response['data'] as Map<String, dynamic>;
        } else {
          userData = response;
        }
      } else {
        throw Exception('Unexpected response format: ${response.runtimeType}');
      }

      final user = User.fromJson(userData);
      await _saveUserData(user);
      _currentUser = user;
      return user;
    } catch (e) {

      // Only clear data if it's definitely a 401 error, not a network issue
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {

        await clearUserData();
      } else {

      }
      return null;
    }
  }

  // Initialize auth service
  static Future<void> initialize() async {
    try {
      await ApiService.initialize();
      
      // Try to get stored user data and validate session
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      final authToken = prefs.getString('auth_token');

      if (userData != null && authToken != null) {
        try {
          // Try to parse stored user data
          try {
            final userJson = json.decode(userData) as Map<String, dynamic>;
            _currentUser = User.fromJson(userJson);

          } catch (e) {

            // Clear corrupted user data
            await prefs.remove('user_data');
            _currentUser = null;
          }
          
          // Force refresh API service token from storage
          await ApiService.refreshTokenFromStorage();
          
          // Validate session with server using getme endpoint
          final user = await getMe();
          if (user != null) {
            _currentUser = user;

          } else {
            // Don't clear data immediately - let the user try again

          }
        } catch (e) {
          // Don't clear data on network errors

        }
      } else {

      }
    } catch (e) {

      await clearUserData();
    }
  }

  // Login user
  static Future<User> login(String email, String password) async {

    // Preload CSRF token before making login request
    await preloadCsrfToken();
    
    final response = await ApiService.post(
      ApiEndpoints.login,
      {
        'email': email,
        'password': password,
      },
      includeCsrf: true, // Explicitly include CSRF token
    );

    // Handle different response formats
    Map<String, dynamic> userData;
    String token;
    
    if (response is Map<String, dynamic>) {
      // Check if response is wrapped in a data field
      if (response.containsKey('data')) {
        final data = response['data'] as Map<String, dynamic>;
        userData = data['user'] as Map<String, dynamic>;
        token = data['token'] as String;
      } else {
        userData = response['user'] as Map<String, dynamic>;
        token = response['token'] as String;
      }
    } else {
      throw Exception('Unexpected response format: ${response.runtimeType}');
    }

    final user = User.fromJson(userData);

    // Save token and user data

    try {
      await ApiService.saveAuthToken(token);

    } catch (e) {

    }

    try {
      await _saveUserData(user);

    } catch (e) {

    }
    
    _currentUser = user;
    
    // Verify token was actually saved

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      if (savedToken == token) {

      } else {

      }
    } catch (e) {

    }
    
    // Force refresh API service token to ensure it's loaded
    await ApiService.refreshTokenFromStorage();
    
    // Add a longer delay for macOS to ensure token is properly set
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Verify token is properly set
    final currentToken = ApiService.getCurrentToken();
    if (currentToken != null) {
    } else {

      // Try to force refresh one more time
      await ApiService.refreshTokenFromStorage();
      final retryToken = ApiService.getCurrentToken();
      if (retryToken != null) {
      } else {

      }
    }

    return user;
  }

  // Register user
  static Future<User> register(String name, String email, String password, String passwordConfirmation) async {

    // Preload CSRF token before making register request
    await preloadCsrfToken();
    
    final response = await ApiService.post(
      ApiEndpoints.register,
      {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      includeCsrf: true, // Explicitly include CSRF token
    );

    // Handle different response formats
    Map<String, dynamic> userData;
    String token;
    
    if (response is Map<String, dynamic>) {
      // Check if response is wrapped in a data field
      if (response.containsKey('data')) {
        final data = response['data'] as Map<String, dynamic>;
        userData = data['user'] as Map<String, dynamic>;
        token = data['token'] as String;
      } else {
        userData = response['user'] as Map<String, dynamic>;
        token = response['token'] as String;
      }
    } else {
      throw Exception('Unexpected response format: ${response.runtimeType}');
    }

    final user = User.fromJson(userData);

    // Save token and user data
    await ApiService.saveAuthToken(token);
    await _saveUserData(user);
    _currentUser = user;

    return user;
  }

  // Logout user
  static Future<void> logout() async {
    try {
      await ApiService.post(ApiEndpoints.logout, {}, includeCsrf: true);
    } catch (e) {
      // Even if logout fails on server, clear local data
    }

    await clearUserData();
  }

  // Get current user from server
  static Future<User?> getCurrentUser() async {
    try {
      final response = await ApiService.get(ApiEndpoints.user);
      
      // Handle different response formats
      Map<String, dynamic> userData;
      if (response is Map<String, dynamic>) {
        // Check if response is wrapped in a data field
        if (response.containsKey('data')) {
          userData = response['data'] as Map<String, dynamic>;
        } else {
          userData = response;
        }
      } else {
        throw Exception('Unexpected response format: ${response.runtimeType}');
      }
      
      final user = User.fromJson(userData);
      await _saveUserData(user);
      _currentUser = user;
      return user;
    } catch (e) {
      await clearUserData();
      return null;
    }
  }

  // Save user data to storage
  static Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = json.encode(user.toJson()); // Use proper JSON encoding
    await prefs.setString('user_data', userJson);
  }

  // Clear user data from storage
  static Future<void> clearUserData() async {
    _currentUser = null;
    await ApiService.clearAuthToken();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }
  
  // Clear corrupted data and start fresh
  static Future<void> clearCorruptedData() async {

    await clearUserData();

  }
}

 