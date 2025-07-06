# Data Clear Guide - Fresh API Sync

This guide explains how to clear local data for a fresh sync with the Laravel API.

## Why Clear Data?

When you want to:
- **Fresh Start**: Remove all local data and sync fresh from API
- **Debug Issues**: Clear corrupted or outdated local data
- **Test API**: Ensure app works with fresh API data only
- **Development**: Reset app state during development

## Methods to Clear Data

### 1. **Settings Page (Recommended)**

Navigate to the Settings page in the app:

1. Open the app
2. Go to **Settings** (bottom navigation)
3. Choose one of these options:

#### **Refresh from API**
- Clears local projects and tasks
- Fetches fresh data from server
- Keeps authentication data
- **Best for**: Regular data refresh

#### **Clear Projects & Tasks**
- Removes only project and task data
- Keeps authentication and user data
- **Best for**: Testing with fresh project data

#### **Clear All Data**
- Removes everything (projects, tasks, auth tokens, preferences)
- Forces logout
- **Best for**: Complete fresh start

### 2. **Programmatic Clearing**

For developers, you can clear data programmatically:

```dart
import 'package:your_app/core/utils/data_clear_util.dart';

// Clear all data
await DataClearUtil.clearAllDataForFreshSync();

// Clear only projects and tasks
await DataClearUtil.clearProjectsAndTasks();

// Print current data statistics
await DataClearUtil.printDataStatistics();
```

### 3. **Manual App Data Clear**

#### **Android**
1. Go to **Settings** > **Apps** > **Project Manager**
2. Tap **Storage** > **Clear Data**
3. Restart the app

#### **iOS**
1. Go to **Settings** > **General** > **iPhone Storage**
2. Find **Project Manager**
3. Tap **Delete App** and reinstall

## Data Statistics

The app tracks local data statistics:

- **Projects**: Number of local projects
- **Tasks**: Number of local tasks  
- **Auth Token**: Whether authentication token exists
- **User Data**: Whether user data is stored

View these in Settings > Local Data Statistics.

## What Gets Cleared

### **Clear All Data**
- ✅ Projects (Hive box)
- ✅ Tasks (Hive box)
- ✅ Authentication tokens (SharedPreferences)
- ✅ User data (SharedPreferences)
- ✅ App preferences (SharedPreferences)

### **Clear Projects & Tasks**
- ✅ Projects (Hive box)
- ✅ Tasks (Hive box)
- ❌ Authentication tokens
- ❌ User data
- ❌ App preferences

### **Refresh from API**
- ✅ Projects (Hive box)
- ✅ Tasks (Hive box)
- ❌ Authentication tokens
- ❌ User data
- ❌ App preferences
- ✅ Fetches fresh data from API

## After Clearing Data

### **Authentication**
- If you cleared auth data, you'll need to log in again
- If you kept auth data, you'll remain logged in

### **Data Sync**
- App will automatically fetch fresh data from API
- Projects and tasks will be loaded from server
- Local storage will be repopulated with fresh data

### **Offline Behavior**
- If API is unavailable, app will show empty state
- Data will sync when connection is restored

## Development Tips

### **Debug Mode**
The app prints data statistics on startup in debug mode:

```
📊 Getting data statistics...
📈 Data Statistics:
   Projects: 5
   Tasks: 12
   Has Auth Token: Yes
   Has User Data: Yes
```

### **Force Fresh Start**
For complete fresh start during development:

```dart
// In your development code
await DataClearUtil.clearAllDataForFreshSync();
// Restart app
```

### **Check Data State**
```dart
// Print current data statistics
await DataClearUtil.printDataStatistics();
```

## Troubleshooting

### **Data Not Clearing**
- Ensure you have proper permissions
- Check if app is in background
- Try manual app data clear

### **API Sync Issues**
- Verify API server is running
- Check network connectivity
- Review API response format

### **Authentication Issues**
- Clear all data and re-login
- Check API authentication endpoints
- Verify token format

## Best Practices

1. **Regular Refresh**: Use "Refresh from API" weekly
2. **Development**: Clear all data before testing new features
3. **Debugging**: Check data statistics when investigating issues
4. **Production**: Use Settings page for user-initiated clears

## API Integration Notes

- Data clearing works with the Laravel API integration
- Cleared data will be re-synced from server
- Offline fallback ensures app remains functional
- Authentication state is preserved unless explicitly cleared

## Commands Summary

| Action | Clears | Keeps | Best For |
|--------|--------|-------|----------|
| Refresh from API | Projects, Tasks | Auth, User Data | Regular refresh |
| Clear Projects & Tasks | Projects, Tasks | Auth, User Data | Testing |
| Clear All Data | Everything | Nothing | Fresh start |
| Manual App Clear | Everything | Nothing | Complete reset | 