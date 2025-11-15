import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../projects/domain/entities/project.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../projects/presentation/widgets/project_share_dialog.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../../../tasks/presentation/widgets/create_task_dialog.dart';
import '../../../../core/widgets/permission_wrapper.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class WorkspacePage extends ConsumerStatefulWidget {
  const WorkspacePage({super.key});

  @override
  ConsumerState<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends ConsumerState<WorkspacePage> {
  final Map<String, bool> _expandedProjects = {};
  ProjectStatus? _statusFilter = ProjectStatus.active; // Default to active

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workspace'),
        actions: [
          // Status Filter Dropdown
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButton<ProjectStatus?>(
              value: _statusFilter,
              underline: const SizedBox(),
              icon: const Icon(Icons.filter_list, size: 20),
              style: Theme.of(context).textTheme.bodyMedium,
              dropdownColor: AppColors.surface,
              items: [
                DropdownMenuItem<ProjectStatus?>(
                  value: null,
                  child: Row(
                    children: [
                      Icon(Icons.all_inclusive, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      const Text('All'),
                    ],
                  ),
                ),
                DropdownMenuItem<ProjectStatus?>(
                  value: ProjectStatus.active,
                  child: Row(
                    children: [
                      Icon(Icons.play_circle, size: 16, color: AppColors.success),
                      const SizedBox(width: 8),
                      const Text('Active'),
                    ],
                  ),
                ),
                DropdownMenuItem<ProjectStatus?>(
                  value: ProjectStatus.completed,
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text('Completed'),
                    ],
                  ),
                ),
                DropdownMenuItem<ProjectStatus?>(
                  value: ProjectStatus.archived,
                  child: Row(
                    children: [
                      Icon(Icons.archive, size: 16, color: AppColors.textTertiary),
                      const SizedBox(width: 8),
                      const Text('Archived'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _statusFilter = value;
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(projectsListProvider);
              ref.invalidate(taskNotifierProvider);
            },
          ),
        ],
      ),
      body: projectsAsync.when(
        data: (projects) => _buildWorkspace(projects),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget(error),
      ),
    );
  }

  Widget _buildWorkspace(List<Project> projects) {
    // Filter projects by status
    final filteredProjects = _statusFilter == null
        ? projects
        : projects.where((p) => p.status == _statusFilter).toList();

    if (filteredProjects.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(projectsListProvider);
        ref.invalidate(taskNotifierProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSizes.md),
        itemCount: filteredProjects.length,
        itemBuilder: (context, index) {
          final project = filteredProjects[index];
          return _buildProjectSection(project);
        },
      ),
    );
  }

  Widget _buildProjectSection(Project project) {
    final isExpanded = _expandedProjects[project.id] ?? false;
    final tasksAsync = ref.watch(kanbanBoardProvider(project.id));

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      child: Column(
        children: [
          _buildProjectHeader(project, isExpanded),
          if (isExpanded)
            tasksAsync.when(
              data: (boardData) => _buildProjectKanban(project, boardData),
              loading: () => const Padding(
                padding: EdgeInsets.all(AppSizes.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: Text(
                  'Error loading tasks: $error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProjectHeader(Project project, bool isExpanded) {
    return InkWell(
      onTap: () => _toggleProjectExpansion(project.id),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getProjectColor(project),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (project.description.isNotEmpty)
                    Text(
                      project.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            _buildProjectStats(project),
            const SizedBox(width: AppSizes.sm),
            IconButton(
              icon: const Icon(Icons.share, size: 20),
              onPressed: () => _showShareDialog(project),
              tooltip: 'Share project',
              color: Theme.of(context).colorScheme.primary,
            ),
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectStats(Project project) {
    final tasksAsync = ref.watch(tasksByProjectIdNotifierProvider(project.id));
    
    return tasksAsync.when(
      data: (tasks) {
        final totalTasks = tasks.length;
        final completedTasks = tasks.where((task) => task.status == TaskStatus.done).length;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$completedTasks/$totalTasks',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'tasks',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => const Icon(Icons.error_outline, size: 16),
    );
  }

  Widget _buildProjectKanban(Project project, Map<TaskStatus, List<Task>> boardData) {
    return Container(
      height: 400,
      padding: const EdgeInsets.fromLTRB(AppSizes.md, 0, AppSizes.md, AppSizes.md),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kanban Board',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  CanCreateTask(
                    child: TextButton.icon(
                      onPressed: () => _showCreateTaskDialog(context, project.id),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Task'),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push('/projects/${project.id}'),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('Full View'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: TaskStatus.values.map((status) {
                  final tasks = boardData[status] ?? [];
                  return _buildStatusColumn(project, status, tasks);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusColumn(Project project, TaskStatus status, List<Task> tasks) {
    const columnWidth = 260.0;
    
    return Container(
      width: columnWidth,
      margin: const EdgeInsets.only(right: AppSizes.sm),
      child: Column(
        children: [
          _buildColumnHeader(status, tasks.length),
          const SizedBox(height: AppSizes.xs),
          Expanded(
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
                          padding: const EdgeInsets.all(AppSizes.xs),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSizes.xs),
                              child: Draggable<Task>(
                                data: task,
                                feedback: Material(
                                  elevation: 8,
                                  child: SizedBox(
                                    width: columnWidth - 20,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.sm),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSizes.xs),
          Expanded(
            child: Text(
              status.displayName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getStatusColor(status),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$taskCount',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyColumn(TaskStatus status) {
    return Container(
      height: 100,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 32,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            'No ${status.displayName.toLowerCase()} tasks',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: AppSizes.md),
          Text(
            'No Projects Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            'Create your first project to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          ElevatedButton.icon(
            onPressed: () => context.push('/projects'),
            icon: const Icon(Icons.add),
            label: const Text('Create Project'),
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
          const SizedBox(height: AppSizes.md),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.lg),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(projectsListProvider);
              ref.invalidate(taskNotifierProvider);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  void _toggleProjectExpansion(String projectId) {
    setState(() {
      _expandedProjects[projectId] = !(_expandedProjects[projectId] ?? false);
    });
  }

  void _showShareDialog(Project project) {
    showDialog(
      context: context,
      builder: (context) => ProjectShareDialog(
        projectId: project.id,
        existingAccessCode: project.accessCode,
      ),
    );
  }

  Color _getProjectColor(Project project) {
    // Generate color based on project ID hash
    final hash = project.id.hashCode;
    final colors = [
      AppColors.primary,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.red,
    ];
    return colors[hash.abs() % colors.length];
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.review:
        return Colors.orange;
      case TaskStatus.done:
        return Colors.green;
    }
  }

  // Task operations
  void _updateTaskStatus(Task task, TaskStatus newStatus) {
    final updatedTask = task.copyWith(status: newStatus);
    ref.read(taskNotifierProvider.notifier).updateTask(updatedTask);
  }

  void _navigateToTaskDetail(Task task) {
    context.push('/tasks/${task.id}');
  }

  void _showCreateTaskDialog(BuildContext context, String projectId) {
    showDialog(
      context: context,
      builder: (context) => CreateTaskDialog(projectId: projectId),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => CreateTaskDialog(
        projectId: task.projectId,
        task: task,
      ),
    );
  }

  void _showDeleteConfirmation(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
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
} 