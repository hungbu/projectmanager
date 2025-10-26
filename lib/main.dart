import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'core/services/auth_service.dart';
import 'core/services/error_handler.dart';
import 'features/projects/data/repositories/project_repository.dart';
import 'features/tasks/data/repositories/task_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Use path-based URLs on web (no # in URL)
  usePathUrlStrategy();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Initialize auth service
  await AuthService.initialize();
  
  // Initialize repositories
  final projectRepository = ProjectRepository();
  final taskRepository = TaskRepository();
  
  await projectRepository.initialize();
  await taskRepository.initialize();
  
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