# API 401 Error Handling & Automatic Redirect Implementation

## Overview
This implementation provides automatic handling of 401 Unauthorized errors from the API, ensuring users are redirected to the login page when their authentication expires.

## Components Added

### 1. Navigation Service (`lib/core/services/navigation_service.dart`)
- Manages global navigation context
- Provides methods for redirecting to login/dashboard
- Handles snackbar notifications

### 2. Error Handler (`lib/core/services/error_handler.dart`)
- Detects 401 errors globally
- Triggers forced logout when 401 is detected
- Integrates with auth providers for state management

### 3. Context Wrapper (`lib/core/widgets/context_wrapper.dart`)
- Wraps the app to provide global context access
- Enables navigation service to work with GoRouter

### 4. API Error Test (`lib/core/utils/api_error_test.dart`)
- Provides testing utilities for 401 error handling
- Includes dialog for testing error scenarios

## How It Works

### 1. API Service Integration
The `ApiService` has been updated to:
- Detect 401 errors in all HTTP responses
- Automatically trigger the error handler when 401 is detected
- Provide detailed logging for debugging

### 2. Error Handler Flow
When a 401 error is detected:
1. Logs the error for debugging
2. Triggers forced logout (clears auth data without API call)
3. Updates auth state via provider
4. Shows user notification
5. Redirects to login page

### 3. Auth Provider Integration
The auth provider now includes:
- `forceLogout()` method for handling 401 errors
- Proper state management during forced logout
- Error handling and logging

### 4. Navigation Integration
- Context wrapper provides global context access
- Navigation service handles redirects
- GoRouter integration for proper navigation

## Testing

### Manual Testing
1. Go to Settings page
2. Tap "Test API Error Handling"
3. Choose test options:
   - "Test 401 Handler" - Simulates 401 error
   - "Test API Call" - Makes actual API call that might return 401

### Automatic Testing
The system automatically handles 401 errors from:
- Project API calls
- Task API calls
- User profile API calls
- Any other authenticated API calls

## Configuration

### Error Handler Setup
The error handler is automatically set up in `main.dart`:
```dart
class _ProviderObserver extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    ErrorHandler.setContainer(container);
  }
}
```

### Navigation Service Setup
The context wrapper is applied in `app.dart`:
```dart
return ContextWrapper(
  child: MaterialApp.router(
    // ... app configuration
  ),
);
```

## Benefits

1. **Automatic Handling**: No manual intervention required
2. **User-Friendly**: Clear notifications and smooth redirects
3. **Secure**: Proper cleanup of auth data
4. **Debuggable**: Comprehensive logging for troubleshooting
5. **Testable**: Built-in testing utilities

## Usage

The implementation works automatically. When any API call returns a 401 error:

1. User sees a notification: "Session expired. Please login again."
2. Auth data is cleared automatically
3. User is redirected to login page
4. User can log in again to continue

## Debugging

Check console logs for:
- `🚨 401 Unauthorized detected` - When 401 is detected
- `✅ Forced logout completed` - When logout is successful
- `🔑 Auth token loaded/saved/cleared` - Token management
- `📡 API call failed` - API call errors

## Future Enhancements

1. **Token Refresh**: Implement automatic token refresh before logout
2. **Retry Logic**: Add retry mechanism for transient 401 errors
3. **Offline Handling**: Handle 401 errors when offline
4. **Custom Messages**: Allow custom error messages per endpoint 