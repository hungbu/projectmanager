import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/data_clear_service.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/widgets/permission_wrapper.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../projects/data/repositories/project_repository.dart';
import '../../../tasks/data/repositories/task_repository.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isClearingData = false;
  Map<String, int> _dataStats = {};

  @override
  void initState() {
    super.initState();
    _loadDataStatistics();
  }

  Future<void> _loadDataStatistics() async {
    final stats = await DataClearService.getDataStatistics();
    setState(() {
      _dataStats = stats;
    });
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will clear all local data including:\n'
          '• Projects and tasks\n'
          '• Authentication tokens\n'
          '• User preferences\n\n'
          'You will need to log in again. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isClearingData = true;
      });

      try {
        await DataClearService.clearAllData();
        
        // Refresh data statistics
        await _loadDataStatistics();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All data cleared successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          
          // Navigate to login
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing data: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isClearingData = false;
          });
        }
      }
    }
  }

  Future<void> _clearProjectsAndTasks() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Projects & Tasks'),
        content: const Text(
          'This will clear all local projects and tasks data.\n'
          'Data will be re-synced from the server when you refresh.\n\n'
          'Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isClearingData = true;
      });

      try {
        // Clear project repository
        final projectRepo = ref.read(projectRepositoryProvider);
        await projectRepo.clearLocalData();

        // Clear task repository
        final taskRepo = ref.read(taskRepositoryProvider);
        await taskRepo.clearLocalData();

        // Refresh data statistics
        await _loadDataStatistics();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Projects and tasks cleared successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error clearing data: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isClearingData = false;
          });
        }
      }
    }
  }

  Future<void> _forceRefreshFromApi() async {
    setState(() {
      _isClearingData = true;
    });

    try {
      // Force refresh projects
      final projectRepo = ref.read(projectRepositoryProvider);
      await projectRepo.forceRefreshFromApi();

      // Force refresh tasks
      final taskRepo = ref.read(taskRepositoryProvider);
      await taskRepo.forceRefreshFromApi();

      // Refresh data statistics
      await _loadDataStatistics();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data refreshed from API successfully'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing data: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isClearingData = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout?\n\n'
          'This will:\n'
          '• Clear your session\n'
          '• Remove authentication token\n'
          '• Keep your local data (projects & tasks)\n\n'
          'You can log back in anytime.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() {
          _isClearingData = true;
        });

        final authNotifier = ref.read(authStateProvider.notifier);
        await authNotifier.logout();
        
        // Refresh data statistics
        await _loadDataStatistics();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: AppColors.success,
            ),
          );
          
          // Navigate to login page
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error during logout: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isClearingData = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isClearingData
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppSizes.lg),
                  Text('Clearing data...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Info Card
                  if (authState.user != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 32,
                                  backgroundColor: AppColors.primary,
                                  child: Text(
                                    authState.user!.fullName.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSizes.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        authState.user!.fullName,
                                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        authState.user!.email,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          PermissionService.getUserRoleDisplayName(),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: AppSizes.lg),
                  
                  // Quick Actions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Actions',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSizes.md),
                          
                          // Dashboard Button
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.dashboard, color: AppColors.primary),
                            ),
                            title: const Text('Dashboard'),
                            subtitle: const Text('View statistics and recent activities'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => context.go('/dashboard'),
                          ),
                          
                          const Divider(),
                          
                          // User Management (Admin only)
                          CanManageUsers(
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.people, color: AppColors.info),
                              ),
                              title: const Text('User Management'),
                              subtitle: const Text('Manage users and permissions'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => context.push('/users'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSizes.lg),
                  
                  // Data Statistics
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Local Data Statistics',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSizes.md),
                          _buildStatItem('Projects', _dataStats['projects'] ?? 0),
                          _buildStatItem('Tasks', _dataStats['tasks'] ?? 0),
                          _buildStatItem('Auth Token', _dataStats['has_auth_token'] ?? 0, isBoolean: true),
                          _buildStatItem('User Data', _dataStats['has_user_data'] ?? 0, isBoolean: true),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSizes.lg),
                  
                  // Account Actions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSizes.md),
                          
                          // Logout Button
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.logout, color: AppColors.error),
                            ),
                            title: const Text('Logout', style: TextStyle(color: AppColors.error)),
                            subtitle: const Text('Sign out of your account'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.error),
                            onTap: _logout,
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, int value, {bool isBoolean = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            isBoolean ? (value == 1 ? 'Yes' : 'No') : value.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 