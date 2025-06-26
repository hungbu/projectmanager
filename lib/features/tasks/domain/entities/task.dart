import 'package:equatable/equatable.dart';

enum TaskStatus {
  todo,
  inProgress,
  done,
  cancelled,
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final String projectId;
  final String? assigneeId;
  final String createdById;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final int estimatedHours;
  final int? actualHours;
  final List<String> attachmentIds;
  final Map<String, dynamic>? metadata;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.projectId,
    this.assigneeId,
    required this.createdById,
    this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.tags,
    required this.estimatedHours,
    this.actualHours,
    required this.attachmentIds,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        priority,
        projectId,
        assigneeId,
        createdById,
        dueDate,
        createdAt,
        updatedAt,
        tags,
        estimatedHours,
        actualHours,
        attachmentIds,
        metadata,
      ];

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    String? projectId,
    String? assigneeId,
    String? createdById,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    int? estimatedHours,
    int? actualHours,
    List<String>? attachmentIds,
    Map<String, dynamic>? metadata,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      projectId: projectId ?? this.projectId,
      assigneeId: assigneeId ?? this.assigneeId,
      createdById: createdById ?? this.createdById,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      actualHours: actualHours ?? this.actualHours,
      attachmentIds: attachmentIds ?? this.attachmentIds,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'projectId': projectId,
      'assigneeId': assigneeId,
      'createdById': createdById,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'estimatedHours': estimatedHours,
      'actualHours': actualHours,
      'attachmentIds': attachmentIds,
      'metadata': metadata,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.todo,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      projectId: json['projectId'] as String,
      assigneeId: json['assigneeId'] as String?,
      createdById: json['createdById'] as String,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      tags: List<String>.from(json['tags'] as List),
      estimatedHours: json['estimatedHours'] as int,
      actualHours: json['actualHours'] as int?,
      attachmentIds: List<String>.from(json['attachmentIds'] as List),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  bool get isCompleted => status == TaskStatus.done;
  bool get isInProgress => status == TaskStatus.inProgress;
  bool get isOverdue => dueDate != null && dueDate!.isBefore(DateTime.now()) && !isCompleted;
  bool get isAssigned => assigneeId != null;
  bool get isHighPriority => priority == TaskPriority.high || priority == TaskPriority.urgent;
} 