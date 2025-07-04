import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';

class DataClearService {
  // Clear all local data
  static Future<void> clearAllData() async {
    try {
      // Clear Hive boxes
      await _clearHiveData();
      
      // Clear SharedPreferences
      await _clearSharedPreferences();
      
      // Clear auth data
      await AuthService.clearUserData();
      
      print('All local data cleared successfully');
    } catch (e) {
      print('Error clearing local data: $e');
      rethrow;
    }
  }

  // Clear only Hive data (projects and tasks)
  static Future<void> clearHiveData() async {
    try {
      await _clearHiveData();
      print('Hive data cleared successfully');
    } catch (e) {
      print('Error clearing Hive data: $e');
      rethrow;
    }
  }

  // Clear only SharedPreferences data
  static Future<void> clearSharedPreferencesData() async {
    try {
      await _clearSharedPreferences();
      print('SharedPreferences data cleared successfully');
    } catch (e) {
      print('Error clearing SharedPreferences data: $e');
      rethrow;
    }
  }

  // Clear only auth data
  static Future<void> clearAuthData() async {
    try {
      await AuthService.clearUserData();
      print('Auth data cleared successfully');
    } catch (e) {
      print('Error clearing auth data: $e');
      rethrow;
    }
  }

  // Private method to clear Hive boxes
  static Future<void> _clearHiveData() async {
    // Clear projects box
    final projectsBox = await Hive.openBox<Map>('projects');
    await projectsBox.clear();
    await projectsBox.close();

    // Clear tasks box
    final tasksBox = await Hive.openBox<Map>('tasks');
    await tasksBox.clear();
    await tasksBox.close();

    // Note: Hive.boxes is not available in this version
    // We'll just clear the known boxes (projects and tasks)
  }

  // Private method to clear SharedPreferences
  static Future<void> _clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Get data statistics
  static Future<Map<String, int>> getDataStatistics() async {
    final stats = <String, int>{};
    
    try {
      // Count projects
      final projectsBox = await Hive.openBox<Map>('projects');
      stats['projects'] = projectsBox.length;
      await projectsBox.close();

      // Count tasks
      final tasksBox = await Hive.openBox<Map>('tasks');
      stats['tasks'] = tasksBox.length;
      await tasksBox.close();

      // Check auth data
      final prefs = await SharedPreferences.getInstance();
      final hasAuthToken = prefs.getString('auth_token') != null;
      final hasUserData = prefs.getString('user_data') != null;
      stats['has_auth_token'] = hasAuthToken ? 1 : 0;
      stats['has_user_data'] = hasUserData ? 1 : 0;

    } catch (e) {
      print('Error getting data statistics: $e');
    }

    return stats;
  }
} 