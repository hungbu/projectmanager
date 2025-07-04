import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/auth_service.dart';
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
    
    // Check if we have stored session data
    _checkStoredSession();
  }
  
  Future<void> _checkStoredSession() async {
    try {
      // Use getme endpoint to validate session
      final user = await AuthService.getMe();
      
      // If user is valid, navigate to dashboard
      if (user != null) {
        print('✅ User authenticated via getMe, navigating to dashboard');
        context.go('/dashboard');
      } else {
        print('❌ No valid session, navigating to login');
        context.go('/login');
      }
    } catch (e) {
      print('❌ Error checking session: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 600;
    
    // Handle auth state changes
    ref.listen(authStateProvider, (previous, next) {
      if (!next.isLoading) {
        // Auth state has been determined, let the router handle navigation
        if (next.user != null) {
          print('🚀 User authenticated, navigating to dashboard');
          // User is authenticated, router will redirect to dashboard
        } else {
          print('🔐 No valid session, navigating to login');
          // User is not authenticated, router will redirect to login
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isDesktop ? AppSizes.xl : AppSizes.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 350),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                              color: AppColors.primary,
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
                              color: AppColors.textInverse,
                            ),
                          ),
                          const SizedBox(height: AppSizes.xl),
                          
                          // App Name
                          Text(
                            AppStrings.appName,
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSizes.sm),
                          
                          // App Description
                          Text(
                            AppStrings.appDescription,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: AppSizes.xxl),
                  
                  // Loading Indicator Card
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.xl),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: AppSizes.shadowBlurRadius,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: AppSizes.md),
                          Text(
                            'Validating session via API...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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
                      textColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}