import 'package:flutter/foundation.dart';

import '../services/data_clear_service.dart';

class DataClearUtil {
  // Clear all data for fresh API sync
  static Future<void> clearAllDataForFreshSync() async {
    if (kDebugMode) {
      print('🧹 Clearing all local data for fresh API sync...');
    }
    
    try {
      await DataClearService.clearAllData();
      
      if (kDebugMode) {
        print('✅ All local data cleared successfully');
        print('📱 App will now sync fresh data from API on next run');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing data: $e');
      }
      rethrow;
    }
  }

  // Clear only projects and tasks data
  static Future<void> clearProjectsAndTasks() async {
    if (kDebugMode) {
      print('🧹 Clearing projects and tasks data...');
    }
    
    try {
      await DataClearService.clearHiveData();
      
      if (kDebugMode) {
        print('✅ Projects and tasks data cleared successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing projects and tasks: $e');
      }
      rethrow;
    }
  }

  // Get data statistics for debugging
  static Future<void> printDataStatistics() async {
    if (kDebugMode) {
      print('📊 Getting data statistics...');
      
      try {
        final stats = await DataClearService.getDataStatistics();
        
        print('📈 Data Statistics:');
        print('   Projects: ${stats['projects'] ?? 0}');
        print('   Tasks: ${stats['tasks'] ?? 0}');
        print('   Has Auth Token: ${stats['has_auth_token'] == 1 ? 'Yes' : 'No'}');
        print('   Has User Data: ${stats['has_user_data'] == 1 ? 'Yes' : 'No'}');
      } catch (e) {
        print('❌ Error getting data statistics: $e');
      }
    }
  }

  // Development helper: Clear data and restart app
  static Future<void> clearDataAndRestart() async {
    if (kDebugMode) {
      print('🔄 Clearing data and preparing for restart...');
      
      try {
        await clearAllDataForFreshSync();
        print('✅ Data cleared. Please restart the app for fresh API sync.');
      } catch (e) {
        print('❌ Error during data clear and restart: $e');
      }
    }
  }
} 