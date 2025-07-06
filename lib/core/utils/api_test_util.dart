import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../services/api_service.dart';

class ApiTestUtil {
  // Test API connectivity
  static Future<void> testApiConnectivity() async {
    try {
      print('🔍 Testing API connectivity...');
      
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('📊 API connectivity test - Status: ${response.statusCode}');
      print('📊 Response: ${response.body}');
      
      if (response.statusCode == 401) {
        print('✅ API is reachable but requires authentication');
      } else if (response.statusCode == 200) {
        print('✅ API is reachable and working');
      } else {
        print('❌ API connectivity issue');
      }
    } catch (e) {
      print('❌ API connectivity test failed: $e');
    }
  }
  
  // Test user creation endpoint
  static Future<void> testUserCreation() async {
    try {
      print('🔍 Testing user creation endpoint...');
      
      // First, get a token by logging in
      final loginResponse = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.login}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': 'admin@gmail.com',
          'password': 'password',
        }),
      );
      
      print('📊 Login response status: ${loginResponse.statusCode}');
      print('📊 Login response: ${loginResponse.body}');
      
      if (loginResponse.statusCode == 200) {
        final loginData = json.decode(loginResponse.body);
        final token = loginData['token'];
        
        print('🔑 Got token: ${token.substring(0, 20)}...');
        
        // Now test user creation
        final createResponse = await http.post(
          Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.users}'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'email': 'test@example.com',
            'name': 'Test User',
            'password': 'password123',
            'role': 'user',
          }),
        );
        
        print('📊 User creation response status: ${createResponse.statusCode}');
        print('📊 User creation response: ${createResponse.body}');
        
        if (createResponse.statusCode == 201) {
          print('✅ User creation test successful');
        } else {
          print('❌ User creation test failed');
        }
      } else {
        print('❌ Login failed, cannot test user creation');
      }
    } catch (e) {
      print('❌ User creation test failed: $e');
    }
  }
  
  // Test current API service
  static Future<void> testCurrentApiService() async {
    try {
      print('🔍 Testing current API service...');
      
      // Test with current API service
      final response = await ApiService.post(
        ApiEndpoints.users,
        {
          'email': 'test2@example.com',
          'name': 'Test User 2',
          'password': 'password123',
          'role': 'user',
        },
      );
      
      print('✅ API service test successful: $response');
    } catch (e) {
      print('❌ API service test failed: $e');
    }
  }
} 