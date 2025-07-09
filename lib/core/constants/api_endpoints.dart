class ApiEndpoints {
  // Base URL - Update this to your Laravel API URL
  static const String baseUrl = 'http://pm_api.test/api';
  //static const String baseUrl = 'http://localhost:8000/api';
  //static const String baseUrl = 'https://pm.vnwebsite.net/api';

  // Authentication
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String user = '/user';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  
  // User Management
  static const String users = '/users';
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String changePassword = '/user/change-password';
  static const String uploadAvatar = '/user/avatar';
  
  // Projects
  static const String projects = '/projects';
  static const String projectById = '/projects/{id}';
  static const String projectMembers = '/projects/{id}/members';
  static const String projectStats = '/projects/{id}/stats';
  static const String projectTasks = '/projects/{id}/tasks';
  static const String addProjectMember = '/projects/{id}/add-member';
  static const String removeProjectMember = '/projects/{id}/remove-member';
  
  // Tasks
  static const String tasks = '/tasks';
  static const String taskById = '/tasks/{id}';
  static const String taskComments = '/tasks/{id}/comments';
  static const String taskAttachments = '/tasks/{id}/attachments';
  static const String taskStatus = '/tasks/{id}/status';
  static const String taskAssign = '/tasks/{id}/assign';
  static const String taskUnassign = '/tasks/{id}/unassign';
  
  // Comments
  static const String comments = '/comments';
  static const String commentById = '/comments/{id}';
  
  // Attachments
  static const String attachments = '/attachments';
  static const String attachmentById = '/attachments/{id}';
  static const String uploadAttachment = '/attachments/upload';
  
  // Dashboard
  static const String dashboard = '/dashboard';
  static const String dashboardStats = '/dashboard/stats';
  static const String dashboardActivities = '/dashboard/activities';
  static const String dashboardProjects = '/dashboard/projects';
  static const String dashboardTasks = '/dashboard/tasks';
  
  // Search
  static const String search = '/search';
  static const String searchProjects = '/search/projects';
  static const String searchTasks = '/search/tasks';
  static const String searchUsers = '/search/users';
  
  // Notifications
  static const String notifications = '/notifications';
  static const String notificationById = '/notifications/{id}';
  static const String markAsRead = '/notifications/{id}/read';
  static const String markAllAsRead = '/notifications/read-all';
  
  // Settings
  static const String settings = '/settings';
  static const String updateSettings = '/settings';
  
  // File Upload
  static const String uploadFile = '/upload';
  static const String uploadImage = '/upload/image';
  static const String uploadDocument = '/upload/document';
  
  // WebSocket
  static const String wsUrl = 'wss://api.projectmanager.com/ws';
  static const String wsNotifications = '/ws/notifications';
  static const String wsProjectUpdates = '/ws/projects/{id}';
  static const String wsTaskUpdates = '/ws/tasks/{id}';
  
  // Helper method to replace path parameters
  static String replacePathParams(String endpoint, Map<String, String> params) {
    String result = endpoint;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
} 