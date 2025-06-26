import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../projects/domain/entities/project.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/providers/task_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectNotifierProvider);
    final tasksAsync = ref.watch(taskNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(projectNotifierProvider);
              ref.refresh(taskNotifierProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(projectNotifierProvider);
          ref.refresh(taskNotifierProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(context),
              const SizedBox(height: 24),
              _buildStatisticsSection(context, projectsAsync, tasksAsync),
              const SizedBox(height: 24),
              _buildRecentProjectsSection(context, projectsAsync),
              const SizedBox(height: 24),
              _buildRecentTasksSection(context, tasksAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Here\'s what\'s happening with your projects today.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(
    BuildContext context,
    AsyncValue<List<Project>> projectsAsync,
    AsyncValue<List<Task>> tasksAsync,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Projects',
            projectsAsync.when(
              data: (projects) => projects.length.toString(),
              loading: () => '...',
              error: (_, __) => '0',
            ),
            Icons.folder,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Active Tasks',
            tasksAsync.when(
              data: (tasks) => tasks.where((task) => !task.isCompleted).length.toString(),
              loading: () => '...',
              error: (_, __) => '0',
            ),
            Icons.task,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Completed',
            tasksAsync.when(
              data: (tasks) => tasks.where((task) => task.isCompleted).length.toString(),
              loading: () => '...',
              error: (_, __) => '0',
            ),
            Icons.check_circle,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentProjectsSection(
    BuildContext context,
    AsyncValue<List<Project>> projectsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Projects',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/projects'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        projectsAsync.when(
          data: (projects) {
            final recentProjects = projects.take(3).toList();
            if (recentProjects.isEmpty) {
              return _buildEmptyState(context, 'No projects yet', 'Create your first project to get started');
            }
            return Column(
              children: recentProjects.map((project) => _buildProjectTile(context, project)).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildErrorState(context, error.toString()),
        ),
      ],
    );
  }

  Widget _buildRecentTasksSection(
    BuildContext context,
    AsyncValue<List<Task>> tasksAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Tasks',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/tasks'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        tasksAsync.when(
          data: (tasks) {
            final recentTasks = tasks.take(3).toList();
            if (recentTasks.isEmpty) {
              return _buildEmptyState(context, 'No tasks yet', 'Create tasks to start managing your work');
            }
            return Column(
              children: recentTasks.map((task) => _buildTaskTile(context, task)).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _buildErrorState(context, error.toString()),
        ),
      ],
    );
  }

  Widget _buildProjectTile(BuildContext context, Project project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _parseColor(project.color ?? '#4ECDC4'),
          child: Text(
            project.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          project.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          project.description,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        trailing: _buildStatusChip(context, project.status),
        onTap: () => context.push('/projects/${project.id}'),
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPriorityColor(task.priority),
          child: Icon(
            _getPriorityIcon(task.priority),
            color: Colors.white,
            size: 16,
          ),
        ),
        title: Text(
          task.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            if (task.dueDate != null)
              Text(
                'Due: ${DateFormat('MMM dd').format(task.dueDate!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: task.isOverdue ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.outline,
                  fontWeight: task.isOverdue ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
          ],
        ),
        trailing: _buildStatusChip(context, task.status),
        onTap: () => context.push('/tasks/${task.id}'),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, dynamic status) {
    Color chipColor;
    Color textColor;
    String displayName;

    if (status is ProjectStatus) {
      switch (status) {
        case ProjectStatus.active:
          chipColor = Colors.green.withOpacity(0.1);
          textColor = Colors.green;
          displayName = 'Active';
          break;
        case ProjectStatus.completed:
          chipColor = Colors.blue.withOpacity(0.1);
          textColor = Colors.blue;
          displayName = 'Completed';
          break;
        case ProjectStatus.archived:
          chipColor = Colors.grey.withOpacity(0.1);
          textColor = Colors.grey;
          displayName = 'Archived';
          break;
        case ProjectStatus.onHold:
          chipColor = Colors.orange.withOpacity(0.1);
          textColor = Colors.orange;
          displayName = 'On Hold';
          break;
      }
    } else if (status is TaskStatus) {
      switch (status) {
        case TaskStatus.todo:
          chipColor = Colors.grey.withOpacity(0.1);
          textColor = Colors.grey;
          displayName = 'To Do';
          break;
        case TaskStatus.inProgress:
          chipColor = Colors.blue.withOpacity(0.1);
          textColor = Colors.blue;
          displayName = 'In Progress';
          break;
        case TaskStatus.review:
          chipColor = Colors.orange.withOpacity(0.1);
          textColor = Colors.orange;
          displayName = 'Review';
          break;
        case TaskStatus.done:
          chipColor = Colors.green.withOpacity(0.1);
          textColor = Colors.green;
          displayName = 'Done';
          break;
      }
    } else {
      chipColor = Colors.grey.withOpacity(0.1);
      textColor = Colors.grey;
      displayName = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String subtitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
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
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 8),
            Text(
              'Error loading data',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.urgent:
        return Colors.red;
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.keyboard_arrow_down;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.keyboard_arrow_up;
      case TaskPriority.urgent:
        return Icons.priority_high;
    }
  }
} 