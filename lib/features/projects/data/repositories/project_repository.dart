import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/project.dart';

class ProjectRepository {
  static const String _boxName = 'projects';
  late Box<Map> _box;

  Future<void> initialize() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  Future<List<Project>> getAllProjects() async {
    final projects = <Project>[];
    for (final map in _box.values) {
      projects.add(_fromMap(map));
    }
    return projects;
  }

  Future<Project?> getProjectById(String id) async {
    final map = _box.get(id);
    if (map != null) {
      return _fromMap(map);
    }
    return null;
  }

  Future<List<Project>> getProjectsByUserId(String userId) async {
    final projects = await getAllProjects();
    return projects.where((project) => 
      project.ownerId == userId || project.memberIds.contains(userId)
    ).toList();
  }

  Future<void> createProject(Project project) async {
    await _box.put(project.id, _toMap(project));
  }

  Future<void> updateProject(Project project) async {
    await _box.put(project.id, _toMap(project));
  }

  Future<void> deleteProject(String id) async {
    await _box.delete(id);
  }

  Future<void> addMemberToProject(String projectId, String userId) async {
    final project = await getProjectById(projectId);
    if (project != null) {
      final updatedMemberIds = List<String>.from(project.memberIds);
      if (!updatedMemberIds.contains(userId)) {
        updatedMemberIds.add(userId);
        final updatedProject = project.copyWith(
          memberIds: updatedMemberIds,
          updatedAt: DateTime.now(),
        );
        await updateProject(updatedProject);
      }
    }
  }

  Future<void> removeMemberFromProject(String projectId, String userId) async {
    final project = await getProjectById(projectId);
    if (project != null) {
      final updatedMemberIds = List<String>.from(project.memberIds);
      updatedMemberIds.remove(userId);
      final updatedProject = project.copyWith(
        memberIds: updatedMemberIds,
        updatedAt: DateTime.now(),
      );
      await updateProject(updatedProject);
    }
  }

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
}

// Provider
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
}); 