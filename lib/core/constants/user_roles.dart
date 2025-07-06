enum UserRole {
  admin('Admin'),
  partner('Đối tác'),
  user('User');

  const UserRole(this.displayName);
  final String displayName;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.user,
    );
  }
}

class Permission {
  // Project permissions
  static const String createProject = 'create_project';
  static const String editProject = 'edit_project';
  static const String deleteProject = 'delete_project';
  static const String viewProject = 'view_project';
  static const String addProjectMember = 'add_project_member';
  static const String removeProjectMember = 'remove_project_member';

  // Task permissions
  static const String createTask = 'create_task';
  static const String editTask = 'edit_task';
  static const String deleteTask = 'delete_task';
  static const String viewTask = 'view_task';
  static const String updateTaskStatus = 'update_task_status';
  static const String assignTask = 'assign_task';

  // User management permissions
  static const String createUser = 'create_user';
  static const String editUser = 'edit_user';
  static const String deleteUser = 'delete_user';
  static const String viewUser = 'view_user';

  // All permissions for each role
  static const Map<UserRole, List<String>> rolePermissions = {
    UserRole.admin: [
      // Project permissions
      createProject, editProject, deleteProject, viewProject,
      addProjectMember, removeProjectMember,
      // Task permissions
      createTask, editTask, deleteTask, viewTask,
      updateTaskStatus, assignTask,
      // User management
      createUser, editUser, deleteUser, viewUser,
    ],
    UserRole.partner: [
      // Project permissions - view only
      viewProject,
      // Task permissions - view only
      viewTask,
    ],
    UserRole.user: [
      // Project permissions - view and limited edit
      viewProject,
      // Task permissions - full access to assigned tasks
      createTask, editTask, viewTask, updateTaskStatus, assignTask,
    ],
  };

  // Check if a role has a specific permission
  static bool hasPermission(UserRole role, String permission) {
    return rolePermissions[role]?.contains(permission) ?? false;
  }

  // Get all permissions for a role
  static List<String> getPermissions(UserRole role) {
    return rolePermissions[role] ?? [];
  }
} 