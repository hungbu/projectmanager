import '../../../../core/constants/user_roles.dart';

class User {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle cases where API returns literal strings instead of actual values
    String getName() {
      final name = json['name']?.toString() ?? '';
      // If the value is literally "name", try to get from email
      if (name == 'name' || name.isEmpty) {
        return json['email']?.toString().split('@')[0] ?? 'User';
      }
      return name;
    }
    
    bool getIsActive() {
      final isActive = json['is_active'];
      // If the value is literally "is_active", default to true
      if (isActive == 'is_active') {
        return true;
      }
      // Handle both bool and int values from API
      if (isActive is bool) {
        return isActive;
      }
      if (isActive is int) {
        return isActive == 1;
      }
      return true; // default to true
    }
    
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: getName(),
      role: UserRole.values.firstWhere(
        (role) => role.name == (json['role']?.toString() ?? 'user'),
        orElse: () => UserRole.user,
      ),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      isActive: getIsActive(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': fullName,
      'role': role.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName, role: $role, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 