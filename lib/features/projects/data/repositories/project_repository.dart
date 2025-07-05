import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/project.dart';

class ProjectRepository {
  static const String _boxName = 'projects';
  late Box<Map> _box;

  Future<void> initialize() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  // Get all projects from API
  Future<List<Project>> getAllProjects() async {
    try {
      print('🔍 Fetching projects from API...');
      final response = await ApiService.get(ApiEndpoints.projects);
      print('✅ API Response received: ${response.runtimeType}');
      print('Response content: $response');
      
      List<dynamic> projectsData;
      
      if (response is List<dynamic>) {
        print('📊 Found ${response.length} projects in response');
        projectsData = response;
      } else {
        print('❌ Unexpected response type: ${response.runtimeType}');
        return [];
      }
      
      final projects = projectsData.map((data) {
        print('🔄 Converting project data: ${data.runtimeType}');
        return _fromApiMap(data as Map<String, dynamic>);
      }).toList();
      
      print('✅ Successfully converted ${projects.length} projects');
      return projects;
    } catch (e) {
      print('❌ Error fetching projects from API: $e');
      // Fallback to local storage if API fails
      return _getAllProjectsFromLocal();
    }
  }

  // Get project by ID from API
  Future<Project?> getProjectById(String id) async {
    try {
      final response = await ApiService.get('${ApiEndpoints.projects}/$id');
      return _fromApiMap(response);
    } catch (e) {
      // Fallback to local storage if API fails
      return _getProjectByIdFromLocal(id);
    }
  }

  // Get projects by user ID (filtered on server)
  Future<List<Project>> getProjectsByUserId(String userId) async {
    // The API already returns only user's projects, so we can use getAllProjects
    return getAllProjects();
  }

  // Create project via API
  Future<Project> createProject(Project project) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.projects,
        _toApiMap(project),
      );
      
      final createdProject = _fromApiMap(response);
      await _saveProjectToLocal(createdProject);
      return createdProject;
    } catch (e) {
      // If API fails, save to local storage only
      await _saveProjectToLocal(project);
      return project;
    }
  }

  // Update project via API
  Future<Project> updateProject(Project project) async {
    try {
      final response = await ApiService.put(
        '${ApiEndpoints.projects}/${project.id}',
        _toApiMap(project),
      );
      
      final updatedProject = _fromApiMap(response);
      await _saveProjectToLocal(updatedProject);
      return updatedProject;
    } catch (e) {
      // If API fails, update local storage only
      await _saveProjectToLocal(project);
      return project;
    }
  }

  // Delete project via API
  Future<void> deleteProject(String id) async {
    try {
      await ApiService.delete('${ApiEndpoints.projects}/$id');
    } catch (e) {
      // Continue with local deletion even if API fails
    }
    
    await _deleteProjectFromLocal(id);
  }

  // Add member to project via API
  Future<void> addMemberToProject(String projectId, String userId) async {
    try {
      await ApiService.post(
        ApiEndpoints.replacePathParams(ApiEndpoints.addProjectMember, {'id': projectId}),
        {'user_id': userId},
      );
    } catch (e) {
      // Handle error or fallback to local update
      final project = await _getProjectByIdFromLocal(projectId);
      if (project != null) {
        final updatedMemberIds = List<String>.from(project.memberIds);
        if (!updatedMemberIds.contains(userId)) {
          updatedMemberIds.add(userId);
          final updatedProject = project.copyWith(
            memberIds: updatedMemberIds,
            updatedAt: DateTime.now(),
          );
          await _saveProjectToLocal(updatedProject);
        }
      }
    }
  }

  // Remove member from project via API
  Future<void> removeMemberFromProject(String projectId, String userId) async {
    try {
      await ApiService.post(
        ApiEndpoints.replacePathParams(ApiEndpoints.removeProjectMember, {'id': projectId}),
        {'user_id': userId},
      );
    } catch (e) {
      // Handle error or fallback to local update
      final project = await _getProjectByIdFromLocal(projectId);
      if (project != null) {
        final updatedMemberIds = List<String>.from(project.memberIds);
        updatedMemberIds.remove(userId);
        final updatedProject = project.copyWith(
          memberIds: updatedMemberIds,
          updatedAt: DateTime.now(),
        );
        await _saveProjectToLocal(updatedProject);
      }
    }
  }

  // Local storage methods (fallback)
  Future<List<Project>> _getAllProjectsFromLocal() async {
    final projects = <Project>[];
    for (final map in _box.values) {
      projects.add(_fromMap(map));
    }
    return projects;
  }

  Future<Project?> _getProjectByIdFromLocal(String id) async {
    final map = _box.get(id);
    if (map != null) {
      return _fromMap(map);
    }
    return null;
  }

  Future<void> _saveProjectToLocal(Project project) async {
    await _box.put(project.id, _toMap(project));
  }

  Future<void> _deleteProjectFromLocal(String id) async {
    await _box.delete(id);
  }

  // Convert API response to Project entity
  Project _fromApiMap(Map<String, dynamic> data) {
    return Project(
      id: data['id'].toString(),
      name: data['name'] as String,
      description: data['description'] as String? ?? '',
      ownerId: data['owner_id'].toString(),
      memberIds: [], // API doesn't return member IDs in this implementation
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: DateTime.parse(data['updated_at']),
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ProjectStatus.active,
      ),
      startDate: data['start_date'] != null 
          ? DateTime.parse(data['start_date'])
          : null,
      endDate: data['end_date'] != null 
          ? DateTime.parse(data['end_date'])
          : null,
      color: data['color'] as String?,
    );
  }

  // Convert Project entity to API request format
  Map<String, dynamic> _toApiMap(Project project) {
    return {
      'name': project.name,
      'description': project.description,
      'status': project.status.name,
      'start_date': project.startDate?.toIso8601String(),
      'end_date': project.endDate?.toIso8601String(),
      'color': project.color,
    };
  }

  // Local storage conversion methods (for fallback)
  Map<String, dynamic> _toMap(Project project) {
    return {
      'id': project.id,
      'name': project.name,
      'description': project.description,
      'ownerId': project.ownerId,
      'memberIds': project.memberIds,
      'createdAt': project.createdAt.toIso8601String(),
      'updatedAt': project.updatedAt.toIso8601String(),
      'status': project.status.name,
      'startDate': project.startDate?.toIso8601String(),
      'endDate': project.endDate?.toIso8601String(),
      'color': project.color,
    };
  }

  Project _fromMap(Map map) {
    return Project(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      ownerId: map['ownerId'] as String,
      memberIds: List<String>.from(map['memberIds'] as List),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ProjectStatus.active,
      ),
      startDate: map['startDate'] != null 
          ? DateTime.parse(map['startDate'] as String)
          : null,
      endDate: map['endDate'] != null 
          ? DateTime.parse(map['endDate'] as String)
          : null,
      color: map['color'] as String?,
    );
  }

  // Clear local data
  Future<void> clearLocalData() async {
    await _box.clear();
  }

  // Force refresh from API (clear local and fetch fresh)
  Future<List<Project>> forceRefreshFromApi() async {
    await clearLocalData();
    return getAllProjects();
  }
}

// Provider
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
}); 