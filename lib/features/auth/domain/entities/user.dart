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
      'fullName': fullName,
      'avatar': avatar,
      'phone': phone,
      'address': address,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'roles': roles,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      avatar: json['avatar'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      bio: json['bio'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool,
      roles: List<String>.from(json['roles'] as List),
    );
  }
} 