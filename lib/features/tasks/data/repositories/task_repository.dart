import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/task.dart';

class TaskRepository {
  static const String _boxName = 'tasks';
  late Box<Map> _box;

  Future<void> initialize() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  // Get all tasks from API
  Future<List<Task>> getAllTasks() async {
    try {
      final response = await ApiService.get(ApiEndpoints.tasks);
      final List<dynamic> tasksData = response as List<dynamic>;
      
      return tasksData.map((data) => _fromApiMap(data as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback to local storage if API fails
      return _getAllTasksFromLocal();
    }
  }

  // Get task by ID from API
  Future<Task?> getTaskById(String id) async {
    try {
      final response = await ApiService.get('${ApiEndpoints.tasks}/$id');
      return _fromApiMap(response);
    } catch (e) {
      // Fallback to local storage if API fails
      return _getTaskByIdFromLocal(id);
    }
  }

  // Get tasks by project ID from API
  Future<List<Task>> getTasksByProjectId(String projectId) async {
    try {
      final response = await ApiService.get('${ApiEndpoints.projects}/$projectId/tasks');
      final List<dynamic> tasksData = response as List<dynamic>;
      
      return tasksData.map((data) => _fromApiMap(data as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback to local storage if API fails
      return _getTasksByProjectIdFromLocal(projectId);
    }
  }

  // Get tasks by assignee ID (filtered on server)
  Future<List<Task>> getTasksByAssigneeId(String assigneeId) async {
    try {
      final response = await ApiService.get('${ApiEndpoints.tasks}?assignee_id=$assigneeId');
      final List<dynamic> tasksData = response as List<dynamic>;
      
      return tasksData.map((data) => _fromApiMap(data as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback to local storage if API fails
      return _getTasksByAssigneeIdFromLocal(assigneeId);
    }
  }

  // Get tasks by status for a project
  Future<List<Task>> getTasksByStatus(String projectId, TaskStatus status) async {
    try {
      final response = await ApiService.get('${ApiEndpoints.tasks}?project_id=$projectId&status=${status.name}');
      final List<dynamic> tasksData = response as List<dynamic>;
      
      return tasksData.map((data) => _fromApiMap(data as Map<String, dynamic>)).toList();
    } catch (e) {
      // Fallback to local storage if API fails
      final tasks = await _getTasksByProjectIdFromLocal(projectId);
      return tasks.where((task) => task.status == status).toList();
    }
  }

  // Create task via API
  Future<Task> createTask(Task task) async {
    try {
      final response = await ApiService.post(
        ApiEndpoints.tasks,
        _toApiMap(task),
      );
      
      final createdTask = _fromApiMap(response);
      await _saveTaskToLocal(createdTask);
      return createdTask;
    } catch (e) {
      // If API fails, save to local storage only
      await _saveTaskToLocal(task);
      return task;
    }
  }

  // Update task via API
  Future<Task> updateTask(Task task) async {
    try {
      final response = await ApiService.put(
        '${ApiEndpoints.tasks}/${task.id}',
        _toApiMap(task),
      );
      
      final updatedTask = _fromApiMap(response);
      await _saveTaskToLocal(updatedTask);
      return updatedTask;
    } catch (e) {
      // If API fails, update local storage only
      await _saveTaskToLocal(task);
      return task;
    }
  }

  // Delete task via API
  Future<void> deleteTask(String id) async {
    try {
      await ApiService.delete('${ApiEndpoints.tasks}/$id');
    } catch (e) {
      // Continue with local deletion even if API fails
    }
    
    await _deleteTaskFromLocal(id);
  }

  // Update task status via API
  Future<Task> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      final response = await ApiService.patch(
        ApiEndpoints.replacePathParams(ApiEndpoints.taskStatus, {'id': taskId}),
        {'status': status.name},
      );
      
      final updatedTask = _fromApiMap(response);
      await _saveTaskToLocal(updatedTask);
      return updatedTask;
    } catch (e) {
      // If API fails, update local storage only
      final task = await _getTaskByIdFromLocal(taskId);
      if (task != null) {
        final updatedTask = task.copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
        await _saveTaskToLocal(updatedTask);
        return updatedTask;
      }
      throw Exception('Task not found');
    }
  }

  // Assign task via API
  Future<Task> assignTask(String taskId, String assigneeId) async {
    try {
      final response = await ApiService.patch(
        ApiEndpoints.replacePathParams(ApiEndpoints.taskAssign, {'id': taskId}),
        {'assignee_id': assigneeId},
      );
      
      final updatedTask = _fromApiMap(response);
      await _saveTaskToLocal(updatedTask);
      return updatedTask;
    } catch (e) {
      // If API fails, update local storage only
      final task = await _getTaskByIdFromLocal(taskId);
      if (task != null) {
        final updatedTask = task.copyWith(
          assigneeId: assigneeId,
          updatedAt: DateTime.now(),
        );
        await _saveTaskToLocal(updatedTask);
        return updatedTask;
      }
      throw Exception('Task not found');
    }
  }

  // Unassign task via API
  Future<Task> unassignTask(String taskId) async {
    try {
      final response = await ApiService.patch(
        ApiEndpoints.replacePathParams(ApiEndpoints.taskUnassign, {'id': taskId}),
        {},
      );
      
      final updatedTask = _fromApiMap(response);
      await _saveTaskToLocal(updatedTask);
      return updatedTask;
    } catch (e) {
      // If API fails, update local storage only
      final task = await _getTaskByIdFromLocal(taskId);
      if (task != null) {
        final updatedTask = task.copyWith(
          assigneeId: null,
          updatedAt: DateTime.now(),
        );
        await _saveTaskToLocal(updatedTask);
        return updatedTask;
      }
      throw Exception('Task not found');
    }
  }

  // Local storage methods (fallback)
  Future<List<Task>> _getAllTasksFromLocal() async {
    final tasks = <Task>[];
    for (final map in _box.values) {
      tasks.add(_fromMap(map));
    }
    return tasks;
  }

  Future<Task?> _getTaskByIdFromLocal(String id) async {
    final map = _box.get(id);
    if (map != null) {
      return _fromMap(map);
    }
    return null;
  }

  Future<List<Task>> _getTasksByProjectIdFromLocal(String projectId) async {
    final tasks = await _getAllTasksFromLocal();
    return tasks.where((task) => task.projectId == projectId).toList();
  }

  Future<List<Task>> _getTasksByAssigneeIdFromLocal(String assigneeId) async {
    final tasks = await _getAllTasksFromLocal();
    return tasks.where((task) => task.assigneeId == assigneeId).toList();
  }

  Future<void> _saveTaskToLocal(Task task) async {
    await _box.put(task.id, _toMap(task));
  }

  Future<void> _deleteTaskFromLocal(String id) async {
    await _box.delete(id);
  }

  // Convert API response to Task entity
  Task _fromApiMap(Map<String, dynamic> data) {
    return Task(
      id: data['id'].toString(),
      title: data['title'] as String,
      description: data['description'] as String? ?? '',
      status: TaskStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => TaskPriority.medium,
      ),
      projectId: data['project_id'].toString(),
      assigneeId: data['assignee_id']?.toString(),
      dueDate: data['due_date'] != null 
          ? DateTime.parse(data['due_date'])
          : null,
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: DateTime.parse(data['updated_at']),
      tags: data['tags'] != null 
          ? List<String>.from(data['tags'] as List)
          : [],
      estimatedHours: data['estimated_hours'] as int?,
      actualHours: data['actual_hours'] as int?,
    );
  }

  // Convert Task entity to API request format
  Map<String, dynamic> _toApiMap(Task task) {
    return {
      'project_id': task.projectId,
      'title': task.title,
      'description': task.description,
      'status': task.status.name,
      'priority': task.priority.name,
      'assignee_id': task.assigneeId,
      'due_date': task.dueDate?.toIso8601String(),
      'estimated_hours': task.estimatedHours,
      'tags': task.tags,
    };
  }

  // Local storage conversion methods (for fallback)
  Map<String, dynamic> _toMap(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'status': task.status.name,
      'priority': task.priority.name,
      'projectId': task.projectId,
      'assigneeId': task.assigneeId,
      'dueDate': task.dueDate?.toIso8601String(),
      'createdAt': task.createdAt.toIso8601String(),
      'updatedAt': task.updatedAt.toIso8601String(),
      'tags': task.tags,
      'estimatedHours': task.estimatedHours,
      'actualHours': task.actualHours,
    };
  }

  Task _fromMap(Map map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      projectId: map['projectId'] as String,
      assigneeId: map['assigneeId'] as String?,
      dueDate: map['dueDate'] != null 
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      tags: List<String>.from(map['tags'] as List),
      estimatedHours: map['estimatedHours'] as int?,
      actualHours: map['actualHours'] as int?,
    );
  }

  // Clear local data
  Future<void> clearLocalData() async {
    await _box.clear();
  }

  // Force refresh from API (clear local and fetch fresh)
  Future<List<Task>> forceRefreshFromApi() async {
    await clearLocalData();
    return getAllTasks();
  }
}

// Provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
}); 