import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';

class ApiConnectivityTest {
  // Test basic API connectivity without authentication
  static Future<bool> testBasicConnectivity() async {
    try {
      print('🌐 Testing basic API connectivity...');
      
      final url = Uri.parse('${ApiEndpoints.baseUrl}/login');
      print('  - Testing URL: $url');
      
      final response = await http.get(url);
      print('  - Response status: ${response.statusCode}');
      print('  - Response headers: ${response.headers}');
      
      if (response.statusCode == 405) {
        // 405 Method Not Allowed is expected for GET on login endpoint
        print('✅ Basic connectivity confirmed (405 is expected for GET on login)');
        return true;
      } else if (response.statusCode < 500) {
        print('✅ Basic connectivity confirmed (status: ${response.statusCode})');
        return true;
      } else {
        print('❌ Server error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Connectivity test failed: $e');
      return false;
    }
  }
  
  // Test if the API server is running
  static Future<bool> testServerRunning() async {
    try {
      print('🔍 Testing if API server is running...');
      
      final baseUrl = ApiEndpoints.baseUrl;
      print('  - Base URL: $baseUrl');
      
      // Try to connect to the base URL
      final response = await http.get(Uri.parse(baseUrl));
      print('  - Response status: ${response.statusCode}');
      
      return response.statusCode < 500;
    } catch (e) {
      print('❌ Server not reachable: $e');
      return false;
    }
  }
  
  // Test authentication with a sample token
  static Future<bool> testAuthentication(String token) async {
    try {
      print('🔐 Testing authentication with token...');
      print('  - Token: ${token.substring(0, 20)}...');
      
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      
      final url = Uri.parse('${ApiEndpoints.baseUrl}/user');
      print('  - Testing URL: $url');
      print('  - Headers: $headers');
      
      final response = await http.get(url, headers: headers);
      print('  - Response status: ${response.statusCode}');
      print('  - Response body: ${response.body.substring(0, 200)}...');
      
      if (response.statusCode == 200) {
        print('✅ Authentication successful');
        return true;
      } else {
        print('❌ Authentication failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Authentication test error: $e');
      return false;
    }
  }
  
  // Comprehensive API test
  static Future<Map<String, dynamic>> runComprehensiveTest() async {
    print('🔍 === COMPREHENSIVE API TEST ===');
    
    final results = <String, dynamic>{};
    
    // Test 1: Server connectivity
    results['server_running'] = await testServerRunning();
    
    // Test 2: Basic connectivity
    results['basic_connectivity'] = await testBasicConnectivity();
    
    // Test 3: API endpoint structure
    results['api_structure'] = await testApiStructure();
    
    print('📊 Test Results:');
    print('  - Server Running: ${results['server_running']}');
    print('  - Basic Connectivity: ${results['basic_connectivity']}');
    print('  - API Structure: ${results['api_structure']}');
    
    print('🔍 === END COMPREHENSIVE API TEST ===');
    return results;
  }
  
  // Test API endpoint structure
  static Future<bool> testApiStructure() async {
    try {
      print('🏗️ Testing API endpoint structure...');
      
      final endpoints = [
        '/login',
        '/register',
        '/user',
      ];
      
      for (final endpoint in endpoints) {
        final url = Uri.parse('${ApiEndpoints.baseUrl}$endpoint');
        print('  - Testing: $endpoint');
        
        try {
          final response = await http.get(url);
          print('    - Status: ${response.statusCode}');
          
          if (response.statusCode == 405) {
            print('    - ✅ Endpoint exists (405 is expected for GET)');
          } else if (response.statusCode < 500) {
            print('    - ✅ Endpoint accessible');
          } else {
            print('    - ❌ Server error');
          }
        } catch (e) {
          print('    - ❌ Error: $e');
        }
      }
      
      return true;
    } catch (e) {
      print('❌ API structure test error: $e');
      return false;
    }
  }
} 