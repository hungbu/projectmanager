import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_endpoints.dart';
import '../../features/projects/domain/entities/project.dart';

/// Service for public access to projects without authentication
class PublicAccessService {
  static const String _baseUrl = ApiEndpoints.baseUrl;

  /// Get project by access code (no auth required)
  static Future<Project> getProjectByAccessCode(String accessCode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/public/project/$accessCode'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Project.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Invalid access code or project not found');
      } else {
        throw Exception('Failed to load project: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching project by access code: $e');
      rethrow;
    }
  }

  /// Get tasks for a project by access code (no auth required)
  static Future<Map<String, dynamic>> getTasksByAccessCode(String accessCode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/public/project/$accessCode/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        throw Exception('Invalid access code or project not found');
      } else {
        throw Exception('Failed to load tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching tasks by access code: $e');
      rethrow;
    }
  }

  /// Verify if an access code is valid (no auth required)
  static Future<Map<String, dynamic>> verifyAccessCode(String accessCode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/public/verify/$accessCode'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'valid': false,
          'message': 'Invalid access code',
        };
      }
    } catch (e) {
      print('❌ Error verifying access code: $e');
      return {
        'valid': false,
        'message': 'Error verifying access code: $e',
      };
    }
  }
}

