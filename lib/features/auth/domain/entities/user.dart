import 'package:equatable/equatable.dart';
import '../../../../core/constants/user_roles.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final String? avatar;
  final String? phone;
  final String? address;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final UserRole role;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatar,
    this.phone,
    this.address,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.role,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        avatar,
        phone,
        address,
        bio,
        createdAt,
        updatedAt,
        isActive,
        role,
      ];

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatar,
    String? phone,
    String? address,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    UserRole? role,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': fullName, // API expects 'name'
      'avatar': avatar,
      'phone': phone,
      'address': address,
      'bio': bio,
      'created_at': createdAt.toIso8601String(), // API uses snake_case
      'updated_at': updatedAt.toIso8601String(), // API uses snake_case
      'is_active': isActive, // API uses snake_case
      'role': role.name, // API expects role name
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      email: json['email'] as String,
      fullName: json['name'] as String, // API returns 'name' not 'fullName'
      avatar: json['avatar'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      bio: json['bio'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String), // API uses snake_case
      updatedAt: DateTime.parse(json['updated_at'] as String), // API uses snake_case
      isActive: json['is_active'] as bool? ?? true, // API might not have this field
      role: UserRole.fromString(json['role'] as String? ?? 'user'), // API returns role name
    );
  }
} 