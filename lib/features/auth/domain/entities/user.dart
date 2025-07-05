import 'package:equatable/equatable.dart';

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
  final List<String> roles;

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
    required this.roles,
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
        roles,
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
    List<String>? roles,
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
      roles: roles ?? this.roles,
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
      'roles': roles,
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
      roles: json['roles'] != null ? List<String>.from(json['roles'] as List) : [], // API might not have roles
    );
  }
} 