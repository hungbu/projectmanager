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
      // Handle integer values (1 = true, 0 = false)
      if (isActive is int) {
        return isActive == 1;
      }
      // Handle boolean values
      if (isActive is bool) {
        return isActive;
      }
      // Handle string values
      if (isActive is String) {
        return isActive.toLowerCase() == 'true' || isActive == '1';
      }
      // Default to true if value is null or unrecognized
      return true;
    }
    
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: getName(),
      avatar: json['avatar']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      bio: json['bio']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      isActive: getIsActive(),
      role: UserRole.fromString(json['role']?.toString() ?? 'user'),
    );
  }
} 