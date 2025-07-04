import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/services/auth_service.dart';
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
  
  runApp(
    const ProviderScope(
      child: ProjectManagerApp(),
    ),
  );
} 