import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: "admin@gmail.com");
  final _passwordController = TextEditingController(text: "123456");
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleRememberMe() {
    setState(() {
      _rememberMe = !_rememberMe;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    print('🔐 === LOGIN PAGE HANDLE LOGIN ===');
    print('📧 Email: ${_emailController.text}');
    print('🔑 Password: ${_passwordController.text.length} characters');

    final authNotifier = ref.read(authStateProvider.notifier);
    print('🔄 Calling auth provider login...');
    await authNotifier.login(_emailController.text, _passwordController.text);
    print('✅ Auth provider login completed');

    // Test API connection to ensure token is working
    await Future.delayed(const Duration(milliseconds: 500)); // Wait for state to settle
    
    // Test API connection only if widget is still mounted
    if (mounted) {
      final success = await ApiService.testApiConnection();
      if (success) {
        print('✅ API connection test passed after login');
      } else {
        print('❌ API connection test failed after login');
        
        // Try macOS-specific fix
        print('🔄 Trying macOS-specific token fix...');
        await ApiService.forceClearAndReinitialize();
        await ApiService.refreshTokenFromStorage();
        
        final retrySuccess = await ApiService.testApiConnection();
        if (retrySuccess) {
          print('✅ API connection test passed after macOS fix');
        } else {
          print('❌ API connection test still failed after macOS fix');
        }
      }
    } else {
      print('⚠️ Widget disposed, skipping API test');
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldRequired;
    }
    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 600;
    
    // Handle auth state changes
    ref.listen(authStateProvider, (previous, next) {
      if (next.user != null && previous?.user == null) {
        // User logged in successfully
        context.go('/dashboard');
      } else if (next.error != null) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
        // Clear error after showing
        ref.read(authStateProvider.notifier).clearError();
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: AppSizes.shadowBlurRadius,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.work_outline,
                            size: 40,
                            color: AppColors.textInverse,
                          ),
                        ),
                        const SizedBox(height: AppSizes.lg),
                        Text(
                          AppStrings.welcomeBack,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.sm),
                        Text(
                          'Đăng nhập để tiếp tục',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSizes.xxl),
                    
                    // Login Form Card
                    Container(
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            decoration: InputDecoration(
                              labelText: AppStrings.email,
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                            ),
                          ),
                          
                          const SizedBox(height: AppSizes.lg),
                          
                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            validator: _validatePassword,
                            decoration: InputDecoration(
                              labelText: AppStrings.password,
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: _togglePasswordVisibility,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                              ),
                              filled: true,
                              fillColor: AppColors.background,
                            ),
                          ),
                          
                          const SizedBox(height: AppSizes.md),
                          
                          // Remember Me & Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) => _toggleRememberMe(),
                                    activeColor: AppColors.primary,
                                  ),
                                  Text(
                                    'Ghi nhớ',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: Navigate to forgot password
                                },
                                child: Text(
                                  AppStrings.forgotPassword,
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: AppSizes.xl),
                          
                          // Login Button
                          CustomButton(
                            text: AppStrings.login,
                            onPressed: _handleLogin,
                            isLoading: authState.isLoading,
                            isFullWidth: true,
                            icon: Icons.login,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: AppSizes.lg),
                    
                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                          child: Text(
                            'hoặc',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    
                    const SizedBox(height: AppSizes.lg),
                    
                    // Social Login Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Implement Google login
                            },
                            icon: const Icon(Icons.g_mobiledata, size: 24),
                            label: const Text('Google'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                              side: BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Implement Facebook login
                            },
                            icon: const Icon(Icons.facebook, size: 24),
                            label: const Text('Facebook'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                              side: BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSizes.xl),
                    
                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.dontHaveAccount,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: Text(
                            AppStrings.signUp,
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 