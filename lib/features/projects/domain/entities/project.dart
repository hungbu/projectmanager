import 'package:equatable/equatable.dart';

enum ProjectStatus {
  planning,
  active,
  onHold,
  completed,
  cancelled,
}

enum ProjectPriority {
  low,
  medium,
  high,
  urgent,
}

class Project extends Equatable {
  final String id;
  final String name;
  final String description;
  final ProjectStatus status;
  final ProjectPriority priority;
  final String ownerId;
  final List<String> memberIds;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? coverImage;
  final Map<String, dynamic>? metadata;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.priority,
    required this.ownerId,
    required this.memberIds,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
    this.coverImage,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        status,
        priority,
        ownerId,
        memberIds,
        startDate,
        endDate,
        createdAt,
        updatedAt,
        coverImage,
        metadata,
      ];

  Project copyWith({
    String? id,
    String? name,
    String? description,
    ProjectStatus? status,
    ProjectPriority? priority,
    String? ownerId,
    List<String>? memberIds,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? coverImage,
    Map<String, dynamic>? metadata,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      ownerId: ownerId ?? this.ownerId,
      memberIds: memberIds ?? this.memberIds,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverImage: coverImage ?? this.coverImage,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'coverImage': coverImage,
      'metadata': metadata,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProjectStatus.planning,
      ),
      priority: ProjectPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => ProjectPriority.medium,
      ),
      ownerId: json['ownerId'] as String,
      memberIds: List<String>.from(json['memberIds'] as List),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      coverImage: json['coverImage'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  bool get isActive => status == ProjectStatus.active;
  bool get isCompleted => status == ProjectStatus.completed;
  bool get isOverdue => endDate != null && endDate!.isBefore(DateTime.now()) && !isCompleted;
} 