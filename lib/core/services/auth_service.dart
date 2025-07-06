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

  // Get current user from server (getme endpoint)
  static Future<User?> getMe() async {
    try {
      final response = await ApiService.get(ApiEndpoints.user);
      
      print('🔍 getMe response: $response');
      
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
      
      print('🔍 User data to parse: $userData');
      
      final user = User.fromJson(userData);
      await _saveUserData(user);
      _currentUser = user;
      return user;
    } catch (e) {
      print('❌ getMe failed: $e');
      print('🔍 Error details: ${e.runtimeType}');
      
      // Only clear data if it's definitely a 401 error, not a network issue
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        print('🚨 Confirmed 401 error - clearing user data');
        await clearUserData();
      } else {
        print('⚠️ Network or other error - keeping user data for retry');
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
      
      print('🔍 Auth initialization - stored data:');
      print('  - User data: ${userData != null ? 'Present' : 'Missing'}');
      print('  - Auth token: ${authToken != null ? 'Present' : 'Missing'}');
      
      if (userData != null && authToken != null) {
        try {
          // Try to parse stored user data
          try {
            final userJson = json.decode(userData) as Map<String, dynamic>;
            _currentUser = User.fromJson(userJson);
            print('✅ Stored user data parsed successfully');
          } catch (e) {
            print('❌ Error parsing stored user data: $e');
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
            print('✅ Session validated successfully via getme endpoint');
          } else {
            // Don't clear data immediately - let the user try again
            print('⚠️ Session validation failed via getme endpoint, but keeping data for retry');
          }
        } catch (e) {
          // Don't clear data on network errors
          print('❌ Session validation error via getme endpoint: $e');
          print('⚠️ Keeping stored data for retry');
        }
      } else {
        print('ℹ️ No stored session found');
      }
    } catch (e) {
      print('❌ Error during auth service initialization: $e');
      await clearUserData();
    }
  }

  // Login user
  static Future<User> login(String email, String password) async {
    print('🔐 === AUTH SERVICE LOGIN START ===');
    print('📧 Email: $email');
    print('🔑 Password: ${password.length} characters');
    final response = await ApiService.post(
      ApiEndpoints.login,
      {
        'email': email,
        'password': password,
      },
    );

    print('🔍 Login response: $response');

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

    print('🔍 User data from login: $userData');
    print('🔍 Token from login: ${token.substring(0, 20)}...');

    final user = User.fromJson(userData);

    // Save token and user data
    print('💾 Starting token save process...');
    try {
      await ApiService.saveAuthToken(token);
      print('✅ Token save completed');
    } catch (e) {
      print('❌ Error saving token: $e');
    }
    
    print('💾 Starting user data save process...');
    try {
      await _saveUserData(user);
      print('✅ User data save completed');
    } catch (e) {
      print('❌ Error saving user data: $e');
    }
    
    _currentUser = user;
    
    // Verify token was actually saved
    print('🔍 Verifying token was saved to storage...');
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      if (savedToken == token) {
        print('✅ Token verification successful - token is in storage');
      } else {
        print('❌ Token verification failed');
        print('  - Expected: ${token.substring(0, 20)}...');
        print('  - Got: ${savedToken?.substring(0, 20) ?? 'null'}...');
      }
    } catch (e) {
      print('❌ Error verifying token: $e');
    }
    
    // Force refresh API service token to ensure it's loaded
    await ApiService.refreshTokenFromStorage();
    
    // Add a longer delay for macOS to ensure token is properly set
    await Future.delayed(const Duration(milliseconds: 200));
    
    // Verify token is properly set
    final currentToken = ApiService.getCurrentToken();
    if (currentToken != null) {
      print('✅ Token properly set after login: ${currentToken.substring(0, 20)}...');
    } else {
      print('⚠️ Token not properly set after login');
      
      // Try to force refresh one more time
      await ApiService.refreshTokenFromStorage();
      final retryToken = ApiService.getCurrentToken();
      if (retryToken != null) {
        print('✅ Token set after retry: ${retryToken.substring(0, 20)}...');
      } else {
        print('❌ Token still not available after retry');
      }
    }

    print('🔐 === AUTH SERVICE LOGIN END ===');
    return user;
  }

  // Register user
  static Future<User> register(String name, String email, String password, String passwordConfirmation) async {
    final response = await ApiService.post(
      ApiEndpoints.register,
      {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    print('🔍 Register response: $response');

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

    print('🔍 User data from register: $userData');
    print('🔍 Token from register: ${token.substring(0, 20)}...');

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
      await ApiService.post(ApiEndpoints.logout, {});
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
    print('🧹 Clearing corrupted data...');
    await clearUserData();
    print('✅ Corrupted data cleared');
  }
}

 