import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/user_roles.dart';
import '../../../users/domain/entities/user.dart';
import '../../../users/presentation/providers/user_providers.dart';
import '../../data/services/project_member_service.dart';

class ProjectMembersDialog extends ConsumerStatefulWidget {
  final String projectId;
  final String projectName;
  final List<User> currentMembers;

  const ProjectMembersDialog({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.currentMembers,
  });

  @override
  ConsumerState<ProjectMembersDialog> createState() => _ProjectMembersDialogState();
}

class _ProjectMembersDialogState extends ConsumerState<ProjectMembersDialog> {
  List<User>? availableUsers;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadAvailableUsers);
  }

  Future<void> _loadAvailableUsers() async {
    try {
      await ref.read(userStateProvider.notifier).loadUsers();
      final usersState = ref.read(userStateProvider);
      
      usersState.when(
        data: (users) {
          setState(() {
            availableUsers = users.where((user) => 
              !widget.currentMembers.any((member) => member.id == user.id)
            ).toList();
          });
        },
        loading: () {},
        error: (error, stackTrace) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error loading users: $error'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _addMember(User user) async {
    setState(() => isLoading = true);
    
    try {
      await ProjectMemberService.addMember(widget.projectId, user.id);
      
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate refresh needed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.fullName} added to project'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding member: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _removeMember(User user) async {
    setState(() => isLoading = true);
    
    try {
      await ProjectMemberService.removeMember(widget.projectId, user.id);
      
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate refresh needed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.fullName} removed from project'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing member: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.partner:
        return Colors.blue;
      case UserRole.user:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(AppSizes.lg),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Project Members',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              Text(
                widget.projectName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSizes.lg),
              
              // Current Members
              Text(
                'Current Members (${widget.currentMembers.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSizes.sm),
              if (widget.currentMembers.isEmpty)
                const Text('No members yet')
              else
                ...widget.currentMembers.map((member) => ListTile(
                  leading: CircleAvatar(
                    child: Text(member.fullName[0].toUpperCase()),
                  ),
                  title: Text(member.fullName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(member.email),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRoleColor(member.role),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          member.role.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: isLoading ? null : () => _removeMember(member),
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                  ),
                )),
              
              const SizedBox(height: AppSizes.lg),
              
              // Available Users
              if (availableUsers != null && availableUsers!.isNotEmpty) ...[
                Text(
                  'Add Members (${availableUsers!.length} available)',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSizes.sm),
                ...availableUsers!.map((user) => ListTile(
                  leading: CircleAvatar(
                    child: Text(user.fullName[0].toUpperCase()),
                  ),
                  title: Text(user.fullName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user.role),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.role.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: isLoading ? null : () => _addMember(user),
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.success),
                  ),
                )),
              ] else if (availableUsers != null && availableUsers!.isEmpty) ...[
                Text(
                  'Add Members',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSizes.sm),
                const Text('No available users to add'),
              ],
              
              const SizedBox(height: AppSizes.lg),
              
              if (isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
} 