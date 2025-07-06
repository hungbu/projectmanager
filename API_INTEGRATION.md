# Flutter Project Manager App - API Integration

This document describes the integration between the Flutter Project Manager app and the Laravel backend API.

## Overview

The Flutter app has been updated to work with the Laravel backend API (`pm_api`) instead of relying solely on local storage. The integration provides:

- **Authentication**: Login, register, and logout functionality
- **Projects**: CRUD operations for projects
- **Tasks**: CRUD operations for tasks with status updates and assignments
- **Offline Support**: Local storage fallback when API is unavailable

## API Endpoints

### Authentication
- `POST /api/login` - User login
- `POST /api/register` - User registration
- `POST /api/logout` - User logout
- `GET /api/user` - Get current user

### Projects
- `GET /api/projects` - Get all user's projects
- `POST /api/projects` - Create new project
- `GET /api/projects/{id}` - Get specific project
- `PUT /api/projects/{id}` - Update project
- `DELETE /api/projects/{id}` - Delete project
- `GET /api/projects/{id}/tasks` - Get tasks for a project

### Tasks
- `GET /api/tasks` - Get all tasks (with optional filters)
- `POST /api/tasks` - Create new task
- `GET /api/tasks/{id}` - Get specific task
- `PUT /api/tasks/{id}` - Update task
- `DELETE /api/tasks/{id}` - Delete task
- `PATCH /api/tasks/{id}/status` - Update task status
- `PATCH /api/tasks/{id}/assign` - Assign task to user
- `PATCH /api/tasks/{id}/unassign` - Unassign task

## Configuration

### API Base URL
Update the base URL in `lib/core/constants/api_endpoints.dart`:

```dart
static const String baseUrl = 'http://localhost:8000/api';
```

Change this to match your Laravel API server URL.

### Dependencies
The following dependencies have been added to `pubspec.yaml`:

```yaml
http: ^1.1.0
shared_preferences: ^2.2.2
```

## Architecture

### Services
- **ApiService**: Handles HTTP requests to the Laravel API
- **AuthService**: Manages authentication state and user sessions

### Repositories
- **ProjectRepository**: Updated to use API with local storage fallback
- **TaskRepository**: Updated to use API with local storage fallback

### State Management
- **AuthProvider**: Manages authentication state using Riverpod
- **ProjectProvider**: Manages project state
- **TaskProvider**: Manages task state

## Features

### Authentication Flow
1. App starts and checks for stored authentication token
2. If token exists, validates with server
3. If valid, user is logged in automatically
4. If invalid or no token, redirects to login page

### Offline Support
- All data operations try API first
- If API fails, fallback to local storage
- Data is synced when connection is restored

### Error Handling
- Network errors are caught and displayed to user
- Validation errors from API are shown
- Graceful degradation when API is unavailable

## Usage

### Starting the Laravel API
1. Navigate to the `pm_api` directory
2. Install dependencies: `composer install`
3. Copy `.env.example` to `.env` and configure database
4. Run migrations: `php artisan migrate`
5. Start the server: `php artisan serve`

### Running the Flutter App
1. Update the API base URL in `api_endpoints.dart`
2. Install dependencies: `flutter pub get`
3. Run the app: `flutter run`

## API Response Format

### Authentication Response
```json
{
  "user": {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "created_at": "2024-01-01T00:00:00.000000Z",
    "updated_at": "2024-01-01T00:00:00.000000Z"
  },
  "token": "1|abc123..."
}
```

### Project Response
```json
{
  "id": 1,
  "name": "Project Name",
  "description": "Project description",
  "owner_id": 1,
  "status": "active",
  "start_date": "2024-01-01",
  "end_date": "2024-12-31",
  "color": "#FF0000",
  "created_at": "2024-01-01T00:00:00.000000Z",
  "updated_at": "2024-01-01T00:00:00.000000Z"
}
```

### Task Response
```json
{
  "id": 1,
  "title": "Task Title",
  "description": "Task description",
  "status": "todo",
  "priority": "medium",
  "project_id": 1,
  "assignee_id": 2,
  "due_date": "2024-12-31",
  "estimated_hours": 8,
  "tags": ["frontend", "ui"],
  "created_at": "2024-01-01T00:00:00.000000Z",
  "updated_at": "2024-01-01T00:00:00.000000Z"
}
```

## Troubleshooting

### Common Issues

1. **API Connection Failed**
   - Check if Laravel server is running
   - Verify API base URL in `api_endpoints.dart`
   - Check network connectivity

2. **Authentication Errors**
   - Clear app data and restart
   - Check if token is valid on server
   - Verify user credentials

3. **Data Not Syncing**
   - Check API response format matches expected
   - Verify database migrations are run
   - Check server logs for errors

### Debug Mode
Enable debug logging by adding to `main.dart`:

```dart
import 'package:http/http.dart' as http;

// Add this before runApp()
http.loggingEnabled = true;
```

## Future Enhancements

- **Real-time Updates**: WebSocket integration for live updates
- **File Upload**: Support for task attachments
- **Push Notifications**: Task assignment and deadline notifications
- **Advanced Filtering**: Server-side filtering and pagination
- **Team Management**: User roles and permissions 