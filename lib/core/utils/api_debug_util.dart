import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_endpoints.dart';
import '../../features/auth/domain/entities/user.dart';

class ApiDebugUtil {
  // Test the /user endpoint directly
  static Future<void> testUserEndpoint(String token) async {
    try {
      print('🔍 Testing /user endpoint with token: ${token.substring(0, 20)}...');
      
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.user}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('📊 Response status: ${response.statusCode}');
      print('📊 Response headers: ${response.headers}');
      print('📊 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Parsed response: $data');
        
        // Test User.fromJson parsing
        try {
          final user = User.fromJson(data);
          print('✅ User parsed successfully: ${user.fullName} (${user.email})');
        } catch (e) {
          print('❌ Error parsing user: $e');
        }
      } else {
        print('❌ API returned error status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error testing user endpoint: $e');
    }
  }
  
  // Test login endpoint
  static Future<void> testLoginEndpoint(String email, String password) async {
    try {
      print('🔍 Testing login endpoint...');
      
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.login}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      
      print('📊 Login response status: ${response.statusCode}');
      print('📊 Login response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Login successful');
        print('📊 Login data: $data');
        
        if (data['token'] != null) {
          print('🔑 Token received: ${data['token'].toString().substring(0, 20)}...');
          
          // Test the user endpoint with the new token
          await testUserEndpoint(data['token']);
        }
      } else {
        print('❌ Login failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error testing login endpoint: $e');
    }
  }
} 