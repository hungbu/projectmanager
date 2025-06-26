import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/task.dart';
import '../providers/task_providers.dart';
import '../widgets/create_task_dialog.dart';

class TaskDetailPage extends ConsumerWidget {
  final String taskId;

  const TaskDetailPage({
    super.key,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskByIdProvider(taskId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          taskAsync.when(
            data: (task) => task != null
                ? PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditTaskDialog(context, ref, task);
                          break;
                        case 'delete':
                          _showDeleteConfirmation(context, ref, task);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit Task'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Task', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: taskAsync.when(
        data: (task) {
          if (task == null) {
            return _buildNotFound(context);
          }
          return _buildTaskDetail(context, ref, task);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(context, error),
      ),
    );
  }

  Widget _buildTaskDetail(BuildContext context, WidgetRef ref, Task task) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(context, task),
          const SizedBox(height: 24),
          _buildStatusSection(context, ref, task),
          const SizedBox(height: 24),
          _buildDetailsSection(context, task),
          const SizedBox(height: 24),
          _buildAssignmentSection(context, task),
          const SizedBox(height: 24),
          _buildTimeSection(context, task),
          const SizedBox(height: 24),
          _buildTagsSection(context, task),
          const SizedBox(height: 24),
          _buildDescriptionSection(context, task),
          const SizedBox(height: 24),
          _buildAttachmentsSection(context, task),
          const SizedBox(height: 24),
          _buildCommentsSection(context, task),
          const SizedBox(height: 24),
          _buildActivitySection(context, task),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, Task task) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildPriorityChip(context, task.priority),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Created on ${DateFormat('MMM dd, yyyy').format(task.createdAt)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, WidgetRef ref, Task task) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaskStatus>(
              value: task.status,
              decoration: const InputDecoration(
                labelText: 'Current Status',
                border: OutlineInputBorder(),
              ),
              items: TaskStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.displayName),
                );
              }).toList(),
              onChanged: (newStatus) {
                if (newStatus != null && newStatus != task.status) {
                  ref.read(taskNotifierProvider.notifier).updateTaskStatus(task.id, newStatus);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, Task task) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(context, 'Task ID', task.id),
            _buildDetailRow(context, 'Project ID', task.projectId),
            _buildDetailRow(context, 'Created', DateFormat('MMM dd, yyyy HH:mm').format(task.createdAt)),
            _buildDetailRow(context, 'Last Updated', DateFormat('MMM dd, yyyy HH:mm').format(task.updatedAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentSection(BuildContext context, Task task) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assignment',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (task.isAssigned) ...[
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      task.assigneeId!.substring(0, 1).toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.assigneeId!.replaceAll('_', ' ').toUpperCase(),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Assigned',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 24,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Unassigned',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection(BuildContext context, Task task) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time & Schedule',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            if (task.dueDate != null) ...[
              _buildDetailRow(
                context,
                'Due Date',
                DateFormat('MMM dd, yyyy').format(task.dueDate!),
                isOverdue: task.isOverdue,
              ),
            ],
            if (task.estimatedHours != null) ...[
              _buildDetailRow(context, 'Estimated Hours', '${task.estimatedHours}h'),
            ],
            if (task.actualHours != null) ...[
              _buildDetailRow(context, 'Actual Hours', '${task.actualHours}h'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context, Task task) {
    if (task.tags.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: task.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tag,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, Task task) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              task.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection(BuildContext context, Task task) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Attachments',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // TODO: Implement file upload
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('File upload coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.attach_file),
                  tooltip: 'Add Attachment',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEmptyState(
              context,
              'No attachments',
              'Add files, documents, or images to this task',
              Icons.attach_file,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsSection(BuildContext context, Task task) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Comments',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // TODO: Implement comment creation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Comments coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.comment),
                  tooltip: 'Add Comment',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildEmptyState(
              context,
              'No comments',
              'Add comments to discuss this task with your team',
              Icons.comment_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection(BuildContext context, Task task) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              context,
              'Task created',
              DateFormat('MMM dd, yyyy HH:mm').format(task.createdAt),
              Icons.add_circle_outline,
            ),
            if (task.updatedAt != task.createdAt)
              _buildActivityItem(
                context,
                'Task updated',
                DateFormat('MMM dd, yyyy HH:mm').format(task.updatedAt),
                Icons.edit_outlined,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isOverdue = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isOverdue ? Theme.of(context).colorScheme.error : null,
                fontWeight: isOverdue ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(BuildContext context, TaskPriority priority) {
    Color chipColor;
    Color textColor;

    switch (priority) {
      case TaskPriority.low:
        chipColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case TaskPriority.medium:
        chipColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      case TaskPriority.high:
        chipColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case TaskPriority.urgent:
        chipColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        priority.displayName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, String title, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Task not found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'The task you\'re looking for doesn\'t exist or has been deleted.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/tasks'),
            child: const Text('Back to Tasks'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, Object error) {
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
            onPressed: () => context.go('/tasks'),
            child: const Text('Back to Tasks'),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, WidgetRef ref, Task task) {
    showDialog(
      context: context,
      builder: (context) => CreateTaskDialog(
        projectId: task.projectId,
        task: task,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Task task) {
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
              context.go('/tasks');
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
}

extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
} 