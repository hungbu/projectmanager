import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../services/navigation_service.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

class AuthStateTest {
  // Test auth state changes
  static void testAuthStateChanges(WidgetRef ref, BuildContext context) {
    print('🧪 === TESTING AUTH STATE CHANGES ===');
    
    try {
      // Get current auth state
      final authState = ref.read(authStateProvider);
      print('📱 Current Auth State:');
      print('  - Is Loading: ${authState.isLoading}');
      print('  - User: ${authState.user?.fullName ?? 'null'}');
      print('  - User ID: ${authState.user?.id ?? 'null'}');
      
      // Test AuthService state
      final isAuthenticated = AuthService.isAuthenticated;
      final currentUser = AuthService.currentUser;
      print('🔍 AuthService State:');
      print('  - Is Authenticated: $isAuthenticated');
      print('  - Current User: ${currentUser?.fullName ?? 'null'}');
      
      // Test context availability
      final contextAvailable = NavigationService.currentContext != null;
      print('🌐 Context State:');
      print('  - Context Available: $contextAvailable');
      
    } catch (e) {
      print('❌ Auth state test failed: $e');
    }
    
    print('🧪 === END AUTH STATE TEST ===');
  }
  
  // Test forced logout with state verification
  static Future<void> testForcedLogout(WidgetRef ref, BuildContext context) async {
    print('🧪 === TESTING FORCED LOGOUT ===');
    
    try {
      // Get initial state
      final initialAuthState = ref.read(authStateProvider);
      print('📱 Initial Auth State:');
      print('  - User: ${initialAuthState.user?.fullName ?? 'null'}');
      
      // Perform forced logout
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.forceLogout();
      
      // Wait a bit for state to update
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Check final state
      final finalAuthState = ref.read(authStateProvider);
      print('📱 Final Auth State:');
      print('  - User: ${finalAuthState.user?.fullName ?? 'null'}');
      print('  - Is Loading: ${finalAuthState.isLoading}');
      
      // Verify AuthService state
      final isAuthenticated = AuthService.isAuthenticated;
      final currentUser = AuthService.currentUser;
      print('🔍 AuthService Final State:');
      print('  - Is Authenticated: $isAuthenticated');
      print('  - Current User: ${currentUser?.fullName ?? 'null'}');
      
      if (finalAuthState.user == null && !isAuthenticated) {
        print('✅ Forced logout successful - user cleared');
      } else {
        print('❌ Forced logout failed - user still present');
      }
      
    } catch (e) {
      print('❌ Forced logout test failed: $e');
    }
    
    print('🧪 === END FORCED LOGOUT TEST ===');
  }
  
  // Test router redirect behavior
  static void testRouterRedirect(WidgetRef ref, BuildContext context) {
    print('🧪 === TESTING ROUTER REDIRECT ===');
    
    try {
      final authState = ref.read(authStateProvider);
      print('📱 Current Auth State for Router:');
      print('  - User: ${authState.user?.fullName ?? 'null'}');
      print('  - Is Loading: ${authState.isLoading}');
      
      if (authState.user == null) {
        print('🔄 User is null - router should redirect to login');
      } else {
        print('🔄 User is authenticated - router should allow access');
      }
      
    } catch (e) {
      print('❌ Router redirect test failed: $e');
    }
    
    print('🧪 === END ROUTER REDIRECT TEST ===');
  }
  
  // Test force refresh auth state
  static Future<void> testForceRefreshAuthState(WidgetRef ref, BuildContext context) async {
    print('🧪 === TESTING FORCE REFRESH AUTH STATE ===');
    
    try {
      // Get initial state
      final initialAuthState = ref.read(authStateProvider);
      print('📱 Initial Auth Provider State:');
      print('  - User: ${initialAuthState.user?.fullName ?? 'null'}');
      
      // Force refresh auth state
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.forceRefreshAuthState();
      
      // Check final state
      final finalAuthState = ref.read(authStateProvider);
      print('📱 Final Auth Provider State:');
      print('  - User: ${finalAuthState.user?.fullName ?? 'null'}');
      
      // Verify AuthService state
      final isAuthenticated = AuthService.isAuthenticated;
      final currentUser = AuthService.currentUser;
      print('🔍 AuthService State:');
      print('  - Is Authenticated: $isAuthenticated');
      print('  - Current User: ${currentUser?.fullName ?? 'null'}');
      
    } catch (e) {
      print('❌ Force refresh auth state test failed: $e');
    }
    
    print('🧪 === END FORCE REFRESH AUTH STATE TEST ===');
  }
  
  // Test force sync with AuthService
  static Future<void> testForceSyncWithAuthService(WidgetRef ref, BuildContext context) async {
    print('🧪 === TESTING FORCE SYNC WITH AUTH SERVICE ===');
    
    try {
      // Get initial state
      final initialAuthState = ref.read(authStateProvider);
      print('📱 Initial Auth Provider State:');
      print('  - User: ${initialAuthState.user?.fullName ?? 'null'}');
      print('  - Is Loading: ${initialAuthState.isLoading}');
      
      // Get AuthService state
      final initialAuthServiceUser = AuthService.currentUser;
      final initialAuthServiceAuthenticated = AuthService.isAuthenticated;
      print('🔍 Initial AuthService State:');
      print('  - Is Authenticated: $initialAuthServiceAuthenticated');
      print('  - Current User: ${initialAuthServiceUser?.fullName ?? 'null'}');
      
      // Force sync with AuthService
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.forceSyncWithAuthService();
      
      // Check final state
      final finalAuthState = ref.read(authStateProvider);
      print('📱 Final Auth Provider State:');
      print('  - User: ${finalAuthState.user?.fullName ?? 'null'}');
      print('  - Is Loading: ${finalAuthState.isLoading}');
      
      // Verify AuthService state
      final finalAuthServiceUser = AuthService.currentUser;
      final finalAuthServiceAuthenticated = AuthService.isAuthenticated;
      print('🔍 Final AuthService State:');
      print('  - Is Authenticated: $finalAuthServiceAuthenticated');
      print('  - Current User: ${finalAuthServiceUser?.fullName ?? 'null'}');
      
      // Check if states are synchronized
      final providerUser = finalAuthState.user;
      final serviceUser = finalAuthServiceUser;
      
      if (providerUser?.id == serviceUser?.id) {
        print('✅ Provider and AuthService states are synchronized');
      } else {
        print('❌ Provider and AuthService states are NOT synchronized');
        print('  - Provider User: ${providerUser?.fullName ?? 'null'}');
        print('  - Service User: ${serviceUser?.fullName ?? 'null'}');
      }
      
    } catch (e) {
      print('❌ Force sync with AuthService test failed: $e');
    }
    
    print('🧪 === END FORCE SYNC WITH AUTH SERVICE TEST ===');
  }
  
  // Test aggressive force logout
  static Future<void> testAggressiveForceLogout(WidgetRef ref, BuildContext context) async {
    print('🧨 === TESTING AGGRESSIVE FORCE LOGOUT ===');
    
    try {
      // Get initial state
      final initialAuthState = ref.read(authStateProvider);
      print('📱 Initial Auth Provider State:');
      print('  - User: ${initialAuthState.user?.fullName ?? 'null'}');
      print('  - User ID: ${initialAuthState.user?.id ?? 'null'}');
      
      // Get AuthService state
      final initialAuthServiceUser = AuthService.currentUser;
      final initialAuthServiceAuthenticated = AuthService.isAuthenticated;
      print('🔍 Initial AuthService State:');
      print('  - Is Authenticated: $initialAuthServiceAuthenticated');
      print('  - Current User: ${initialAuthServiceUser?.fullName ?? 'null'}');
      
      // Perform aggressive force logout
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.aggressiveForceLogout();
      
      // Wait a bit for state to update
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Check final state
      final finalAuthState = ref.read(authStateProvider);
      print('📱 Final Auth Provider State:');
      print('  - User: ${finalAuthState.user?.fullName ?? 'null'}');
      print('  - User ID: ${finalAuthState.user?.id ?? 'null'}');
      print('  - Is Loading: ${finalAuthState.isLoading}');
      
      // Verify AuthService state
      final finalAuthServiceUser = AuthService.currentUser;
      final finalAuthServiceAuthenticated = AuthService.isAuthenticated;
      print('🔍 Final AuthService State:');
      print('  - Is Authenticated: $finalAuthServiceAuthenticated');
      print('  - Current User: ${finalAuthServiceUser?.fullName ?? 'null'}');
      
      // Check if both states are cleared
      if (finalAuthState.user == null && finalAuthServiceUser == null) {
        print('✅ Aggressive logout successful - both states cleared');
      } else {
        print('❌ Aggressive logout failed - states not cleared');
        print('  - Provider User: ${finalAuthState.user?.fullName ?? 'null'}');
        print('  - Service User: ${finalAuthServiceUser?.fullName ?? 'null'}');
      }
      
    } catch (e) {
      print('❌ Aggressive force logout test failed: $e');
    }
    
    print('🧨 === END AGGRESSIVE FORCE LOGOUT TEST ===');
  }
} 