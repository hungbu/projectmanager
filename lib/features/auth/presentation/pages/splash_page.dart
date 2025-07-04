import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.xl),
          child: Column(
            children: [
              const Spacer(),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // App Logo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.textInverse,
                          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: AppSizes.shadowBlurRadius,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.work_outline,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.xl),
                      
                      // App Name
                      Text(
                        AppStrings.appName,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.textInverse,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      
                      // App Description
                      Text(
                        AppStrings.appDescription,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textInverse.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              
              // Loading Indicator
              FadeTransition(
                opacity: _fadeAnimation,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.textInverse),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: AppSizes.xl),
              
              // Skip Button
              FadeTransition(
                opacity: _fadeAnimation,
                child: CustomButton(
                  text: 'Bỏ qua',
                  variant: ButtonVariant.text,
                  onPressed: () => context.go('/login'),
                  textColor: AppColors.textInverse,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}