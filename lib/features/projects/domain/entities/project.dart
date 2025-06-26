import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum ProjectStatus {
  active,
  completed,
  archived,
  onHold;

  String get displayName {
    switch (this) {
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.archived:
        return 'Archived';
      case ProjectStatus.onHold:
        return 'On Hold';
    }
  }
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
  final String ownerId;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ProjectStatus status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? color;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.memberIds,
    required this.createdAt,
    required this.updatedAt,
    this.status = ProjectStatus.active,
    this.startDate,
    this.endDate,
    this.color,
  });

  factory Project.create({
    required String name,
    required String description,
    required String ownerId,
    List<String> memberIds = const [],
    DateTime? startDate,
    DateTime? endDate,
    String? color,
  }) {
    final now = DateTime.now();
    return Project(
      id: const Uuid().v4(),
      name: name,
      description: description,
      ownerId: ownerId,
      memberIds: memberIds,
      createdAt: now,
      updatedAt: now,
      startDate: startDate,
      endDate: endDate,
      color: color,
    );
  }

  Project copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    List<String>? memberIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    ProjectStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? color,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      color: color ?? this.color,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        ownerId,
        memberIds,
        createdAt,
        updatedAt,
        status,
        startDate,
        endDate,
        color,
      ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status.name,
      'priority': ProjectPriority.medium.name,
      'ownerId': ownerId,
      'memberIds': memberIds,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'coverImage': null,
      'metadata': null,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      ownerId: json['ownerId'] as String,
      memberIds: List<String>.from(json['memberIds'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProjectStatus.active,
      ),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      color: null,
    );
  }

  bool get isActive => status == ProjectStatus.active;
  bool get isCompleted => status == ProjectStatus.completed;
  bool get isOverdue => endDate != null && endDate!.isBefore(DateTime.now()) && !isCompleted;
} 