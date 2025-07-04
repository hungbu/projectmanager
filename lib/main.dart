import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/services/auth_service.dart';
import 'core/services/error_handler.dart';
import 'core/services/navigation_service.dart';
import 'core/utils/data_clear_util.dart';
import 'core/utils/token_test_util.dart';
import 'core/utils/session_util.dart';
import 'features/projects/data/repositories/project_repository.dart';
import 'features/tasks/data/repositories/task_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Initialize auth service
  await AuthService.initialize();
  
  // Initialize repositories
  final projectRepository = ProjectRepository();
  final taskRepository = TaskRepository();
  
  await projectRepository.initialize();
  await taskRepository.initialize();
  
  // Print data statistics for debugging
  await DataClearUtil.printDataStatistics();
  
  // Test token functionality
  TokenTestUtil.printTokenInfo();
  
  // Print session information
  await SessionUtil.printSessionInfo();
  
  runApp(
    ProviderScope(
      child: ProjectManagerApp(),
      observers: [
        _ProviderObserver(),
      ],
    ),
  );
}

// Provider observer to set up error handler
class _ProviderObserver extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    // Set up error handler with container
    ErrorHandler.setContainer(container);
  }
}