import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/navigation_service.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

class AuthStateTest {
  // Test auth state changes
  static void testAuthStateChanges(WidgetRef ref, BuildContext context) {

    try {
      // Get current auth state
      final authState = ref.read(authStateProvider);

      // Test AuthService state
      final isAuthenticated = AuthService.isAuthenticated;
      final currentUser = AuthService.currentUser;

      // Test context availability
      final contextAvailable = NavigationService.currentContext != null;

    } catch (e) {

    }

  }
  
  // Test forced logout with state verification
  static Future<void> testForcedLogout(WidgetRef ref, BuildContext context) async {

    try {
      // Get initial state
      final initialAuthState = ref.read(authStateProvider);

      // Perform forced logout
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.forceLogout();
      
      // Wait a bit for state to update
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Check final state
      final finalAuthState = ref.read(authStateProvider);

      // Verify AuthService state
      final isAuthenticated = AuthService.isAuthenticated;
      final currentUser = AuthService.currentUser;

      if (finalAuthState.user == null && !isAuthenticated) {

      } else {

      }
      
    } catch (e) {

    }

  }
  
  // Test router redirect behavior
  static void testRouterRedirect(WidgetRef ref, BuildContext context) {

    try {
      final authState = ref.read(authStateProvider);

      if (authState.user == null) {

      } else {

      }
      
    } catch (e) {

    }

  }
  
  // Test force refresh auth state
  static Future<void> testForceRefreshAuthState(WidgetRef ref, BuildContext context) async {

    try {
      // Get initial state
      final initialAuthState = ref.read(authStateProvider);

      // Force refresh auth state
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.forceRefreshAuthState();
      
      // Check final state
      final finalAuthState = ref.read(authStateProvider);

      // Verify AuthService state
      final isAuthenticated = AuthService.isAuthenticated;
      final currentUser = AuthService.currentUser;

    } catch (e) {

    }

  }
  
  // Test force sync with AuthService
  static Future<void> testForceSyncWithAuthService(WidgetRef ref, BuildContext context) async {

    try {
      // Get initial state
      final initialAuthState = ref.read(authStateProvider);

      // Get AuthService state
      final initialAuthServiceUser = AuthService.currentUser;
      final initialAuthServiceAuthenticated = AuthService.isAuthenticated;

      // Force sync with AuthService
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.forceSyncWithAuthService();
      
      // Check final state
      final finalAuthState = ref.read(authStateProvider);

      // Verify AuthService state
      final finalAuthServiceUser = AuthService.currentUser;
      final finalAuthServiceAuthenticated = AuthService.isAuthenticated;

      // Check if states are synchronized
      final providerUser = finalAuthState.user;
      final serviceUser = finalAuthServiceUser;
      
      if (providerUser?.id == serviceUser?.id) {

      } else {

      }
      
    } catch (e) {

    }

  }
  
  // Test aggressive force logout
  static Future<void> testAggressiveForceLogout(WidgetRef ref, BuildContext context) async {

    try {
      // Get initial state
      final initialAuthState = ref.read(authStateProvider);

      // Get AuthService state
      final initialAuthServiceUser = AuthService.currentUser;
      final initialAuthServiceAuthenticated = AuthService.isAuthenticated;

      // Perform aggressive force logout
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.aggressiveForceLogout();
      
      // Wait a bit for state to update
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Check final state
      final finalAuthState = ref.read(authStateProvider);

      // Verify AuthService state
      final finalAuthServiceUser = AuthService.currentUser;
      final finalAuthServiceAuthenticated = AuthService.isAuthenticated;

      // Check if both states are cleared
      if (finalAuthState.user == null && finalAuthServiceUser == null) {

      } else {

      }
      
    } catch (e) {

    }

  }
} 