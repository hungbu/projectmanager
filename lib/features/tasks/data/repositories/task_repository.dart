import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/task.dart';

class TaskRepository {
  static const String _boxName = 'tasks';
  late Box<Map> _box;

  Future<void> initialize() async {
    _box = await Hive.openBox<Map>(_boxName);
  }

  Future<List<Task>> getAllTasks() async {
    final tasks = <Task>[];
    for (final map in _box.values) {
      tasks.add(_fromMap(map));
    }
    return tasks;
  }

  Future<Task?> getTaskById(String id) async {
    final map = _box.get(id);
    if (map != null) {
      return _fromMap(map);
    }
    return null;
  }

  Future<List<Task>> getTasksByProjectId(String projectId) async {
    final tasks = await getAllTasks();
    return tasks.where((task) => task.projectId == projectId).toList();
  }

  Future<List<Task>> getTasksByAssigneeId(String assigneeId) async {
    final tasks = await getAllTasks();
    return tasks.where((task) => task.assigneeId == assigneeId).toList();
  }

  Future<List<Task>> getTasksByStatus(String projectId, TaskStatus status) async {
    final tasks = await getTasksByProjectId(projectId);
    return tasks.where((task) => task.status == status).toList();
  }

  Future<void> createTask(Task task) async {
    await _box.put(task.id, _toMap(task));
  }

  Future<void> updateTask(Task task) async {
    await _box.put(task.id, _toMap(task));
  }

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    final task = await getTaskById(taskId);
    if (task != null) {
      final updatedTask = task.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      await updateTask(updatedTask);
    }
  }

  Future<void> assignTask(String taskId, String assigneeId) async {
    final task = await getTaskById(taskId);
    if (task != null) {
      final updatedTask = task.copyWith(
        assigneeId: assigneeId,
        updatedAt: DateTime.now(),
      );
      await updateTask(updatedTask);
    }
  }

  Future<void> unassignTask(String taskId) async {
    final task = await getTaskById(taskId);
    if (task != null) {
      final updatedTask = task.copyWith(
        assigneeId: null,
        updatedAt: DateTime.now(),
      );
      await updateTask(updatedTask);
    }
  }

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
}

// Provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
}); 