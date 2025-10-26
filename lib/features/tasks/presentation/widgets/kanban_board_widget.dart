import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';
import 'task_card.dart';
import '../../../../core/constants/app_colors.dart';

/// Reusable Kanban Board Widget
/// Can be used for both private (editable) and public (read-only) views
class KanbanBoardWidget extends StatelessWidget {
  final Map<TaskStatus, List<dynamic>> boardData;
  final bool isReadOnly;
  final Function(dynamic task, TaskStatus newStatus)? onTaskStatusChanged;
  final Function(dynamic task)? onTaskTap;
  final Function(dynamic task)? onTaskEdit;
  final Function(dynamic task)? onTaskDelete;

  const KanbanBoardWidget({
    super.key,
    required this.boardData,
    this.isReadOnly = false,
    this.onTaskStatusChanged,
    this.onTaskTap,
    this.onTaskEdit,
    this.onTaskDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            height: constraints.maxHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: TaskStatus.values.map((status) {
                final tasks = boardData[status] ?? [];
                return _buildStatusColumn(context, status, tasks, constraints.maxHeight);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusColumn(
    BuildContext context,
    TaskStatus status,
    List<dynamic> tasks,
    double maxHeight,
  ) {
    // Fixed column width for consistent sizing
    const columnWidth = 300.0;

    return Container(
      width: columnWidth,
      height: maxHeight,
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _buildColumnHeader(context, status, tasks.length),
          const SizedBox(height: 8),
          Expanded(
            child: _buildColumnContent(context, status, tasks, columnWidth),
          ),
        ],
      ),
    );
  }

  Widget _buildColumnContent(
    BuildContext context,
    TaskStatus status,
    List<dynamic> tasks,
    double columnWidth,
  ) {
    if (isReadOnly) {
      // Read-only view (for public access)
      return _buildReadOnlyColumn(context, status, tasks);
    } else {
      // Editable view (for authenticated users)
      return _buildEditableColumn(context, status, tasks, columnWidth);
    }
  }

  Widget _buildReadOnlyColumn(
    BuildContext context,
    TaskStatus status,
    List<dynamic> tasks,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: tasks.isEmpty
          ? _buildEmptyColumn(context, status)
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildReadOnlyTaskCard(context, task),
                );
              },
            ),
    );
  }

  Widget _buildEditableColumn(
    BuildContext context,
    TaskStatus status,
    List<dynamic> tasks,
    double columnWidth,
  ) {
    return DragTarget<Object>(
      onWillAccept: (task) {
        if (task == null) return false;
        // Check if task has status field
        if (task is Task) {
          return task.status != status;
        } else if (task is Map) {
          return task['status'] != status.name;
        }
        return false;
      },
      onAccept: (task) {
        if (onTaskStatusChanged != null) {
          onTaskStatusChanged!(task, status);
        }
      },
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
              ? _buildEmptyColumn(context, status)
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildDraggableTaskCard(context, task, columnWidth),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildDraggableTaskCard(
    BuildContext context,
    dynamic task,
    double columnWidth,
  ) {
    return Draggable<Object>(
      data: task,
      feedback: Material(
        elevation: 8,
        child: SizedBox(
          width: columnWidth - 20,
          child: _buildTaskCardWidget(context, task),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildTaskCardWidget(context, task),
      ),
      child: _buildTaskCardWidget(context, task),
    );
  }

  Widget _buildTaskCardWidget(BuildContext context, dynamic task) {
    if (task is Task) {
      // If it's a Task entity, use TaskCard widget
      return TaskCard(
        task: task,
        onTap: onTaskTap != null ? () => onTaskTap!(task) : () {},
        onEdit: onTaskEdit != null ? () => onTaskEdit!(task) : () {},
        onDelete: onTaskDelete != null ? () => onTaskDelete!(task) : () {},
      );
    } else {
      // If it's a Map (from public API), build custom card
      return _buildReadOnlyTaskCard(context, task);
    }
  }

  Widget _buildReadOnlyTaskCard(BuildContext context, Map<String, dynamic> task) {
    final priority = task['priority']?.toString() ?? 'medium';
    Color priorityColor;

    switch (priority.toLowerCase()) {
      case 'urgent':
        priorityColor = AppColors.error;
        break;
      case 'high':
        priorityColor = AppColors.warning;
        break;
      case 'medium':
        priorityColor = AppColors.info;
        break;
      case 'low':
        priorityColor = AppColors.success;
        break;
      default:
        priorityColor = AppColors.textSecondary;
    }

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTaskTap != null ? () => onTaskTap!(task) : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 20,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task['title']?.toString() ?? 'Untitled',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (task['description'] != null &&
                  task['description'].toString().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task['description'].toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      priority.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: priorityColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                    ),
                  ),
                  const Spacer(),
                  if (task['due_date'] != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(DateTime.parse(task['due_date'].toString())),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                ],
              ),
              if (task['assignee'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        task['assignee']['name']
                                ?.toString()
                                .substring(0, 1)
                                .toUpperCase() ??
                            '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        task['assignee']['name']?.toString() ?? 'Unassigned',
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColumnHeader(BuildContext context, TaskStatus status, int taskCount) {
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

  Widget _buildEmptyColumn(BuildContext context, TaskStatus status) {
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
          if (!isReadOnly) ...[
            const SizedBox(height: 8),
            Text(
              'Drag tasks here or create new ones',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

