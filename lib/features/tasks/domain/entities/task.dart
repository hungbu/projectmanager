import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String projectId;
  final String? assigneeId;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final int? estimatedHours;
  final int? actualHours;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.projectId,
    this.assigneeId,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.estimatedHours,
    this.actualHours,
  });

  factory Task.create({
    required String title,
    required String description,
    required String projectId,
    TaskPriority priority = TaskPriority.medium,
    String? assigneeId,
    DateTime? dueDate,
    List<String> tags = const [],
    int? estimatedHours,
  }) {
    final now = DateTime.now();
    return Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      status: TaskStatus.todo,
      priority: priority,
      projectId: projectId,
      assigneeId: assigneeId,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
      tags: tags,
      estimatedHours: estimatedHours,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? projectId,
    String? assigneeId,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    int? estimatedHours,
    int? actualHours,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      projectId: projectId ?? this.projectId,
      assigneeId: assigneeId ?? this.assigneeId,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
    );
  }

  // Computed properties
  bool get isCompleted => status == TaskStatus.done;
  bool get isInProgress => status == TaskStatus.inProgress;
  bool get isOverdue => dueDate != null && dueDate!.isBefore(DateTime.now()) && !isCompleted;
  bool get isAssigned => assigneeId != null;
  bool get isHighPriority => priority == TaskPriority.high || priority == TaskPriority.urgent;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        priority,
        projectId,
        assigneeId,
        dueDate,
        createdAt,
        updatedAt,
        tags,
        estimatedHours,
        actualHours,
      ];
}

enum TaskStatus {
  todo,
  inProgress,
  review,
  done;

  String get displayName {
    switch (this) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.review:
        return 'Review';
      case TaskStatus.done:
        return 'Done';
    }
  }

  int get order {
    switch (this) {
      case TaskStatus.todo:
        return 0;
      case TaskStatus.inProgress:
        return 1;
      case TaskStatus.review:
        return 2;
      case TaskStatus.done:
        return 3;
    }
  }
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  int get order {
    switch (this) {
      case TaskPriority.low:
        return 0;
      case TaskPriority.medium:
        return 1;
      case TaskPriority.high:
        return 2;
      case TaskPriority.urgent:
        return 3;
    }
  }
} 