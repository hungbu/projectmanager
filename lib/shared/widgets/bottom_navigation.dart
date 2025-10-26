import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/user_roles.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

class CustomBottomNavigation extends ConsumerWidget {
  const CustomBottomNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final authState = ref.watch(authStateProvider);
    final isAdmin = authState.user?.role == UserRole.admin;
    
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: AppSizes.shadowBlurRadius,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.view_agenda_outlined,
                activeIcon: Icons.view_agenda,
                label: 'Workspace',
                route: '/workspace',
                isActive: location == '/workspace',
              ),
              // Only show Projects tab for admin users
              if (isAdmin)
                _buildNavItem(
                  context,
                  icon: Icons.folder_outlined,
                  activeIcon: Icons.folder,
                  label: 'Projects',
                  route: '/projects',
                  isActive: location == '/projects',
                ),
              _buildNavItem(
                context,
                icon: Icons.person_outlined,
                activeIcon: Icons.person,
                label: 'Profile',
                route: '/settings',
                isActive: location == '/settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.xs,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textTertiary,
              size: AppSizes.iconMd,
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isActive ? AppColors.primary : AppColors.textTertiary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 