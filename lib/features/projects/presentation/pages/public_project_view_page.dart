import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/public_access_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/widgets/kanban_board_widget.dart';

class PublicProjectViewPage extends StatefulWidget {
  final String accessCode;

  const PublicProjectViewPage({
    super.key,
    required this.accessCode,
  });

  @override
  State<PublicProjectViewPage> createState() => _PublicProjectViewPageState();
}

class _PublicProjectViewPageState extends State<PublicProjectViewPage> {
  bool _isLoading = true;
  String? _error;
  Project? _project;
  Map<TaskStatus, List<dynamic>> _kanbanBoard = {};

  @override
  void initState() {
    super.initState();
    _loadProjectData();
  }

  Future<void> _loadProjectData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load project info
      final project = await PublicAccessService.getProjectByAccessCode(widget.accessCode);
      
      // Load tasks
      final tasksData = await PublicAccessService.getTasksByAccessCode(widget.accessCode);
      
      // Parse kanban board data
      final kanbanData = tasksData['kanban_board'] as Map<String, dynamic>?;
      final Map<TaskStatus, List<dynamic>> kanbanBoard = {};
      
      if (kanbanData != null) {
        kanbanBoard[TaskStatus.todo] = List<dynamic>.from(kanbanData['todo'] ?? []);
        kanbanBoard[TaskStatus.inProgress] = List<dynamic>.from(kanbanData['in_progress'] ?? []);
        kanbanBoard[TaskStatus.review] = List<dynamic>.from(kanbanData['review'] ?? []);
        kanbanBoard[TaskStatus.done] = List<dynamic>.from(kanbanData['done'] ?? []);
      }

      setState(() {
        _project = project;
        _kanbanBoard = kanbanBoard;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_project?.name ?? 'Project View'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjectData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_project == null) {
      return const Center(
        child: Text('Project not found'),
      );
    }

    return Column(
      children: [
        _buildProjectHeader(),
        const Divider(height: 1),
        Expanded(
          child: _buildKanbanBoard(),
        ),
      ],
    );
  }

  Widget _buildProjectHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: _project?.color != null 
                      ? Color(int.parse(_project!.color!.replaceFirst('#', '0xff')))
                      : AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  _project!.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusBadge(_project!.status),
            ],
          ),
          if (_project!.description.isNotEmpty) ...[
            const SizedBox(height: AppSizes.sm),
            Text(
              _project!.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (_project!.startDate != null || _project!.endDate != null) ...[
            const SizedBox(height: AppSizes.sm),
            Row(
              children: [
                if (_project!.startDate != null) ...[
                  const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Start: ${_formatDate(_project!.startDate!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: AppSizes.md),
                ],
                if (_project!.endDate != null) ...[
                  const Icon(Icons.event, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'End: ${_formatDate(_project!.endDate!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: AppSizes.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.sm,
              vertical: AppSizes.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.visibility, size: 16, color: AppColors.info),
                const SizedBox(width: 4),
                Text(
                  'Public View - Read Only',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ProjectStatus status) {
    Color statusColor;
    String statusText;

    switch (status) {
      case ProjectStatus.active:
        statusColor = AppColors.success;
        statusText = 'Active';
        break;
      case ProjectStatus.completed:
        statusColor = AppColors.primary;
        statusText = 'Completed';
        break;
      case ProjectStatus.archived:
        statusColor = AppColors.textTertiary;
        statusText = 'Archived';
        break;
      case ProjectStatus.onHold:
        statusColor = AppColors.warning;
        statusText = 'On Hold';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildKanbanBoard() {
    return KanbanBoardWidget(
      boardData: _kanbanBoard,
      isReadOnly: true,
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
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
              'Unable to Load Project',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadProjectData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

