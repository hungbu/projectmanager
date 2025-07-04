import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/data_clear_service.dart';
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
        title: const Text('Settings'),
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
                  
                  // Data Management
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Data Management',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppSizes.lg),
                          
                          // Force Refresh from API
                          ListTile(
                            leading: const Icon(Icons.refresh),
                            title: const Text('Refresh from API'),
                            subtitle: const Text('Clear local data and fetch fresh from server'),
                            onTap: _forceRefreshFromApi,
                          ),
                          
                          const Divider(),
                          
                          // Clear Projects & Tasks
                          ListTile(
                            leading: const Icon(Icons.clear_all),
                            title: const Text('Clear Projects & Tasks'),
                            subtitle: const Text('Remove all local project and task data'),
                            onTap: _clearProjectsAndTasks,
                          ),
                          
                          const Divider(),
                          
                                                     // Clear All Data
                           ListTile(
                             leading: const Icon(Icons.delete_forever, color: AppColors.error),
                             title: const Text('Clear All Data', style: TextStyle(color: AppColors.error)),
                             subtitle: const Text('Remove all local data and logout'),
                             onTap: _clearAllData,
                           ),
                           
                           const Divider(),
                           
                           // User Info
                           if (authState.user != null)
                             Card(
                               child: Padding(
                                 padding: const EdgeInsets.all(AppSizes.lg),
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(
                                       'User Information',
                                       style: Theme.of(context).textTheme.titleLarge,
                                     ),
                                     const SizedBox(height: AppSizes.md),
                                     _buildUserInfoItem('Name', authState.user!.name),
                                     _buildUserInfoItem('Email', authState.user!.email),
                                     _buildUserInfoItem('User ID', authState.user!.id.toString()),
                                     const SizedBox(height: AppSizes.md),
                                     const Divider(),
                                     const SizedBox(height: AppSizes.sm),
                                     SizedBox(
                                       width: double.infinity,
                                       child: OutlinedButton.icon(
                                         onPressed: _logout,
                                         icon: const Icon(Icons.logout, color: AppColors.error),
                                         label: const Text('Logout', style: TextStyle(color: AppColors.error)),
                                         style: OutlinedButton.styleFrom(
                                           side: const BorderSide(color: AppColors.error),
                                           padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                                         ),
                                       ),
                                     ),
                                   ],
                                 ),
                               ),
                             ),
                          
                          const SizedBox(height: AppSizes.lg),

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

  Widget _buildUserInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 