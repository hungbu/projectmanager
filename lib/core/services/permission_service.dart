import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/user_roles.dart';
import '../../features/auth/domain/entities/user.dart';
import 'auth_service.dart';

class PermissionService {
  // Check if current user has a specific permission
  static bool hasPermission(String permission) {
    final user = AuthService.currentUser;
    if (user == null) return false;
    
    return Permission.hasPermission(user.role, permission);
  }

  // Check if current user has any of the given permissions
  static bool hasAnyPermission(List<String> permissions) {
    final user = AuthService.currentUser;
    if (user == null) return false;
    
    return permissions.any((permission) => 
      Permission.hasPermission(user.role, permission)
    );
  }

  // Check if current user has all of the given permissions
  static bool hasAllPermissions(List<String> permissions) {
    final user = AuthService.currentUser;
    if (user == null) return false;
    
    return permissions.every((permission) => 
      Permission.hasPermission(user.role, permission)
    );
  }

  // Check if current user is admin
  static bool isAdmin() {
    final user = AuthService.currentUser;
    return user?.role == UserRole.admin;
  }

  // Check if current user is partner
  static bool isPartner() {
    final user = AuthService.currentUser;
    return user?.role == UserRole.partner;
  }

  // Check if current user is regular user
  static bool isUser() {
    final user = AuthService.currentUser;
    return user?.role == UserRole.user;
  }

  // Check if user can edit project
  static bool canEditProject() {
    return hasPermission(Permission.editProject);
  }

  // Check if user can delete project
  static bool canDeleteProject() {
    return hasPermission(Permission.deleteProject);
  }

  // Check if user can create project
  static bool canCreateProject() {
    return hasPermission(Permission.createProject);
  }

  // Check if user can view project
  static bool canViewProject() {
    return hasPermission(Permission.viewProject);
  }

  // Check if user can edit task
  static bool canEditTask() {
    return hasPermission(Permission.editTask);
  }

  // Check if user can delete task
  static bool canDeleteTask() {
    return hasPermission(Permission.deleteTask);
  }

  // Check if user can create task
  static bool canCreateTask() {
    return hasPermission(Permission.createTask);
  }

  // Check if user can update task status
  static bool canUpdateTaskStatus() {
    return hasPermission(Permission.updateTaskStatus);
  }

  // Check if user can assign task
  static bool canAssignTask() {
    return hasPermission(Permission.assignTask);
  }

  // Check if user can manage users (admin only)
  static bool canManageUsers() {
    return hasPermission(Permission.createUser) || 
           hasPermission(Permission.editUser) || 
           hasPermission(Permission.deleteUser);
  }

  // Check if user can add members to project
  static bool canAddProjectMember() {
    return hasPermission(Permission.addProjectMember);
  }

  // Check if user can remove members from project
  static bool canRemoveProjectMember() {
    return hasPermission(Permission.removeProjectMember);
  }

  // Get user's role display name
  static String getUserRoleDisplayName() {
    final user = AuthService.currentUser;
    return user?.role.displayName ?? 'Unknown';
  }

  // Get all permissions for current user
  static List<String> getCurrentUserPermissions() {
    final user = AuthService.currentUser;
    if (user == null) return [];
    
    return Permission.getPermissions(user.role);
  }
}

// Provider for permission service
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
}); 