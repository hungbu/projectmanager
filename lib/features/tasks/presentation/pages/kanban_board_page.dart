import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';
import '../widgets/kanban_board_widget.dart';
import '../widgets/create_task_dialog.dart';
import '../../../../core/widgets/permission_wrapper.dart';

class KanbanBoardPage extends ConsumerStatefulWidget {
  final String projectId;
  
  const KanbanBoardPage({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<KanbanBoardPage> createState() => _KanbanBoardPageState();
}

class _KanbanBoardPageState extends ConsumerState<KanbanBoardPage> {
  @override
  Widget build(BuildContext context) {
    final kanbanData = ref.watch(kanbanBoardProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kanban Board'),
        actions: [
          CanCreateTask(
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateTaskDialog(context),
            ),
          ),
        ],
      ),
      body: kanbanData.when(
        data: (boardData) => KanbanBoardWidget(
          boardData: boardData,
          isReadOnly: false,
          onTaskStatusChanged: _updateTaskStatus,
          onTaskTap: _navigateToTaskDetail,
          onTaskEdit: _showEditTaskDialog,
          onTaskDelete: _showDeleteConfirmation,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(error),
      ),
    );
  }

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.refresh(kanbanBoardProvider(widget.projectId)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _updateTaskStatus(dynamic task, TaskStatus newStatus) {
    if (task is Task) {
      ref.read(taskNotifierProvider.notifier).updateTaskStatus(task.id, newStatus);
    }
  }

  void _showCreateTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateTaskDialog(projectId: widget.projectId),
    );
  }

  void _showEditTaskDialog(dynamic task) {
    if (task is Task) {
      showDialog(
        context: context,
        builder: (context) => CreateTaskDialog(projectId: widget.projectId, task: task),
      );
    }
  }

  void _showDeleteConfirmation(dynamic task) {
    if (task is! Task) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(taskNotifierProvider.notifier).deleteTask(task.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _navigateToTaskDetail(dynamic task) {
    if (task is Task) {
      context.push('/tasks/${task.id}');
    }
  }
} 