import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/task_repository.dart';
import '../../domain/entities/task.dart';

// Task list provider
final tasksProvider = FutureProvider<List<Task>>((ref) async {
  final repository = ref.read(taskRepositoryProvider);
  await repository.initialize();
  return repository.getAllTasks();
});

// Task by ID provider
final taskByIdProvider = FutureProvider.family<Task?, String>((ref, id) async {
  final repository = ref.read(taskRepositoryProvider);
  await repository.initialize();
  return repository.getTaskById(id);
});

// Tasks by project ID provider
final tasksByProjectIdProvider = FutureProvider.family<List<Task>, String>((ref, projectId) async {
  final repository = ref.read(taskRepositoryProvider);
  await repository.initialize();
  return repository.getTasksByProjectId(projectId);
});

// Tasks by assignee ID provider
final tasksByAssigneeIdProvider = FutureProvider.family<List<Task>, String>((ref, assigneeId) async {
  final repository = ref.read(taskRepositoryProvider);
  await repository.initialize();
  return repository.getTasksByAssigneeId(assigneeId);
});

// Tasks by status provider
final tasksByStatusProvider = FutureProvider.family<List<Task>, ({String projectId, TaskStatus status})>((ref, params) async {
  final repository = ref.read(taskRepositoryProvider);
  await repository.initialize();
  return repository.getTasksByStatus(params.projectId, params.status);
});

// Task notifier for CRUD operations
class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repository;

  TaskNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      await _repository.initialize();
      final tasks = await _repository.getAllTasks();
      state = AsyncValue.data(tasks);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createTask(Task task) async {
    try {
      await _repository.createTask(task);
      await _loadTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await _repository.updateTask(task);
      await _loadTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _repository.deleteTask(id);
      await _loadTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      await _repository.updateTaskStatus(taskId, status);
      await _loadTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> assignTask(String taskId, String assigneeId) async {
    try {
      await _repository.assignTask(taskId, assigneeId);
      await _loadTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> unassignTask(String taskId) async {
    try {
      await _repository.unassignTask(taskId);
      await _loadTasks();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final taskNotifierProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
  final repository = ref.read(taskRepositoryProvider);
  return TaskNotifier(repository);
});

// Tasks by project ID that depends on the task notifier
final tasksByProjectIdNotifierProvider = FutureProvider.family<List<Task>, String>((ref, projectId) async {
  // Watch the task notifier to get updates
  final tasksAsync = ref.watch(taskNotifierProvider);
  
  return tasksAsync.when(
    data: (tasks) => tasks.where((task) => task.projectId == projectId).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

// Kanban board provider - groups tasks by status for a specific project
// Now depends on the task notifier for automatic updates
final kanbanBoardProvider = FutureProvider.family<Map<TaskStatus, List<Task>>, String>((ref, projectId) async {
  // Watch the task notifier to get updates
  final tasksAsync = ref.watch(taskNotifierProvider);
  
  return tasksAsync.when(
    data: (allTasks) {
      final projectTasks = allTasks.where((task) => task.projectId == projectId).toList();
      final groupedTasks = <TaskStatus, List<Task>>{};
      
      for (final status in TaskStatus.values) {
        groupedTasks[status] = projectTasks.where((task) => task.status == status).toList();
      }
      
      return groupedTasks;
    },
    loading: () {
      final groupedTasks = <TaskStatus, List<Task>>{};
      for (final status in TaskStatus.values) {
        groupedTasks[status] = [];
      }
      return groupedTasks;
    },
    error: (_, __) {
      final groupedTasks = <TaskStatus, List<Task>>{};
      for (final status in TaskStatus.values) {
        groupedTasks[status] = [];
      }
      return groupedTasks;
    },
  );
}); 