import '../../../../core/services/api_service.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../users/domain/entities/user.dart';

class ProjectMemberService {
  // Get project members
  static Future<List<User>> getProjectMembers(String projectId) async {
    try {
      final response = await ApiService.get('${ApiEndpoints.projects}/$projectId/members');
      
      if (response is List) {
        return response.map((userJson) => User.fromJson(userJson)).toList();
      }
      
      throw Exception('Unexpected response format');
    } catch (e) {
      throw Exception('Error loading project members: $e');
    }
  }

  // Add member to project
  static Future<void> addMember(String projectId, String userId) async {
    try {
      await ApiService.post(
        '${ApiEndpoints.projects}/$projectId/add-member',
        {'user_id': userId},
      );
    } catch (e) {
      throw Exception('Error adding member to project: $e');
    }
  }

  // Remove member from project
  static Future<void> removeMember(String projectId, String userId) async {
    try {
      await ApiService.post(
        '${ApiEndpoints.projects}/$projectId/remove-member',
        {'user_id': userId},
      );
    } catch (e) {
      throw Exception('Error removing member from project: $e');
    }
  }
} 