import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/project_repository.dart';
import '../../domain/entities/project.dart';

// Project list provider
final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final repository = ref.read(projectRepositoryProvider);
  await repository.initialize();
  return repository.getAllProjects();
});

// Project by ID provider
final projectByIdProvider = FutureProvider.family<Project?, String>((ref, id) async {
  final repository = ref.read(projectRepositoryProvider);
  await repository.initialize();
  return repository.getProjectById(id);
});

// Projects by user ID provider
final projectsByUserIdProvider = FutureProvider.family<List<Project>, String>((ref, userId) async {
  final repository = ref.read(projectRepositoryProvider);
  await repository.initialize();
  return repository.getProjectsByUserId(userId);
});

// Project notifier for CRUD operations
class ProjectNotifier extends StateNotifier<AsyncValue<List<Project>>> {
  final ProjectRepository _repository;

  ProjectNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      await _repository.initialize();
      final projects = await _repository.getAllProjects();
      state = AsyncValue.data(projects);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createProject(Project project) async {
    try {
      await _repository.createProject(project);
      await _loadProjects();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      await _repository.updateProject(project);
      await _loadProjects();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      await _repository.deleteProject(id);
      await _loadProjects();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addMemberToProject(String projectId, String userId) async {
    try {
      await _repository.addMemberToProject(projectId, userId);
      await _loadProjects();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> removeMemberFromProject(String projectId, String userId) async {
    try {
      await _repository.removeMemberFromProject(projectId, userId);
      await _loadProjects();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final projectNotifierProvider = StateNotifierProvider<ProjectNotifier, AsyncValue<List<Project>>>((ref) {
  final repository = ref.read(projectRepositoryProvider);
  return ProjectNotifier(repository);
});

// Projects list that depends on the project notifier for automatic updates
final projectsListProvider = FutureProvider<List<Project>>((ref) async {
  final projectsAsync = ref.watch(projectNotifierProvider);
  
  return projectsAsync.when(
    data: (projects) => projects,
    loading: () => [],
    error: (_, __) => [],
  );
});

// Project by ID that depends on the project notifier
final projectByIdNotifierProvider = FutureProvider.family<Project?, String>((ref, id) async {
  final projectsAsync = ref.watch(projectNotifierProvider);
  
  return projectsAsync.when(
    data: (projects) => projects.where((project) => project.id == id).firstOrNull,
    loading: () => null,
    error: (_, __) => null,
  );
}); 