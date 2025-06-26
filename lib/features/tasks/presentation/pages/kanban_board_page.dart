import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';
import '../widgets/task_card.dart';
import '../widgets/create_task_dialog.dart';

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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateTaskDialog(context),
          ),
        ],
      ),
      body: kanbanData.when(
        data: (boardData) => _buildKanbanBoard(boardData),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(error),
      ),
    );
  }

  Widget _buildKanbanBoard(Map<TaskStatus, List<Task>> boardData) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: TaskStatus.values.map((status) {
          final tasks = boardData[status] ?? [];
          return _buildStatusColumn(status, tasks);
        }).toList(),
      ),
    );
  }

  Widget _buildStatusColumn(TaskStatus status, List<Task> tasks) {
    return Container(
      width: 300,
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _buildColumnHeader(status, tasks.length),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(
              minHeight: 400,
              maxHeight: 600,
            ),
            child: DragTarget<Task>(
              onWillAccept: (task) => task != null && task.status != status,
              onAccept: (task) => _updateTaskStatus(task, status),
              builder: (context, candidateData, rejectedData) {
                return Container(
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: candidateData.isNotEmpty
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: tasks.isEmpty
                      ? _buildEmptyColumn(status)
                      : ListView.builder(
                          padding: const EdgeInsets.all(8.0),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Draggable<Task>(
                                data: task,
                                feedback: Material(
                                  elevation: 8,
                                  child: SizedBox(
                                    width: 280,
                                    child: TaskCard(
                                      task: task,
                                      onTap: () => _navigateToTaskDetail(task),
                                      onEdit: () => _showEditTaskDialog(context, task),
                                      onDelete: () => _showDeleteConfirmation(task),
                                    ),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.5,
                                  child: TaskCard(
                                    task: task,
                                    onTap: () => _navigateToTaskDetail(task),
                                    onEdit: () => _showEditTaskDialog(context, task),
                                    onDelete: () => _showDeleteConfirmation(task),
                                  ),
                                ),
                                child: TaskCard(
                                  task: task,
                                  onTap: () => _navigateToTaskDetail(task),
                                  onEdit: () => _showEditTaskDialog(context, task),
                                  onDelete: () => _showDeleteConfirmation(task),
                                ),
                              ),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnHeader(TaskStatus status, int taskCount) {
    Color headerColor;
    IconData headerIcon;

    switch (status) {
      case TaskStatus.todo:
        headerColor = Colors.grey;
        headerIcon = Icons.radio_button_unchecked;
        break;
      case TaskStatus.inProgress:
        headerColor = Colors.blue;
        headerIcon = Icons.play_circle_outline;
        break;
      case TaskStatus.review:
        headerColor = Colors.orange;
        headerIcon = Icons.visibility;
        break;
      case TaskStatus.done:
        headerColor = Colors.green;
        headerIcon = Icons.check_circle_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: headerColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: headerColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(headerIcon, color: headerColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              status.displayName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: headerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: headerColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              taskCount.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: headerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyColumn(TaskStatus status) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Drag tasks here or create new ones',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
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

  void _updateTaskStatus(Task task, TaskStatus newStatus) {
    ref.read(taskNotifierProvider.notifier).updateTaskStatus(task.id, newStatus);
  }

  void _showCreateTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateTaskDialog(projectId: widget.projectId),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => CreateTaskDialog(projectId: widget.projectId, task: task),
    );
  }

  void _showDeleteConfirmation(Task task) {
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

  void _navigateToTaskDetail(Task task) {
    context.push('/tasks/${task.id}');
  }
} 