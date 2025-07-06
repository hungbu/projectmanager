import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../users/domain/entities/user.dart';

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
  final List<User>? users;
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
    this.users,
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
    List<User>? users,
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
      users: users ?? this.users,
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
        users,
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
    // Handle API response format
    List<User>? users;
    if (json['users'] != null) {
      users = (json['users'] as List)
          .map((userJson) => User.fromJson(userJson))
          .toList();
    }

    return Project(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      ownerId: json['owner_id']?.toString() ?? '',
      memberIds: json['memberIds'] != null 
          ? List<String>.from(json['memberIds'] as List)
          : [],
      users: users,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == (json['status']?.toString() ?? 'active'),
        orElse: () => ProjectStatus.active,
      ),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'].toString())
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'].toString())
          : null,
      color: json['color']?.toString(),
    );
  }

  bool get isActive => status == ProjectStatus.active;
  bool get isCompleted => status == ProjectStatus.completed;
  bool get isOverdue => endDate != null && endDate!.isBefore(DateTime.now()) && !isCompleted;
} 