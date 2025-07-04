import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/auth_service.dart';

// Auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Auth state
class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Initialize auth service (this will validate session with server)
      await AuthService.initialize();
      
      final user = AuthService.currentUser;
      if (user != null) {
        state = state.copyWith(user: user, isLoading: false);
        print('✅ Auth initialized with valid session');
      } else {
        state = state.copyWith(isLoading: false);
        print('ℹ️ Auth initialized - no valid session');
      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      print('❌ Auth initialization error: $e');
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await AuthService.login(email, password);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> register(String name, String email, String password, String passwordConfirmation) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final user = await AuthService.register(name, email, password, passwordConfirmation);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      await AuthService.logout();
      state = state.copyWith(user: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> refreshUser() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final user = await AuthService.getCurrentUser();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
  
  // Force logout (for 401 errors)
  Future<void> forceLogout() async {
    print('🔄 Starting forced logout in auth provider...');
    print('📱 Initial auth provider state:');
    print('  - User: ${state.user?.name ?? 'null'}');
    print('  - User ID: ${state.user?.id ?? 'null'}');
    
    try {
      // Clear auth data without API call
      await AuthService.clearUserData();
      
      // Verify AuthService state
      final isAuthenticated = AuthService.isAuthenticated;
      final currentUser = AuthService.currentUser;
      print('🔍 AuthService state after clear:');
      print('  - Is Authenticated: $isAuthenticated');
      print('  - Current User: ${currentUser?.name ?? 'null'}');
      
      // Create a completely new state object to force update
      final newState = AuthState(
        isLoading: false,
        user: null,
        error: null,
      );
      
      // Update state with new object
      state = newState;
      print('✅ Created new state object with null user');
      
      // Verify the state was updated
      print('📱 State after first update:');
      print('  - User: ${state.user?.name ?? 'null'}');
      print('  - User ID: ${state.user?.id ?? 'null'}');
      print('  - Is Loading: ${state.isLoading}');
      
      // Add a small delay to ensure state is updated
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Force another state update with explicit null
      state = state.copyWith(user: null);
      print('🔄 Second state update with explicit null');
      
      // Verify final state
      final finalState = state;
      print('📱 Final auth provider state:');
      print('  - User: ${finalState.user?.name ?? 'null'}');
      print('  - User ID: ${finalState.user?.id ?? 'null'}');
      print('  - Is Loading: ${finalState.isLoading}');
      
      // Double-check AuthService state
      final finalAuthServiceUser = AuthService.currentUser;
      final finalAuthServiceAuthenticated = AuthService.isAuthenticated;
      print('🔍 Final AuthService state:');
      print('  - Is Authenticated: $finalAuthServiceAuthenticated');
      print('  - Current User: ${finalAuthServiceUser?.name ?? 'null'}');
      
      // Verify the state is actually null
      if (finalState.user != null) {
        print('❌ Forced logout failed - user still present');
        print('  - User name: ${finalState.user?.name}');
        print('  - User ID: ${finalState.user?.id}');
        
        // Try one more aggressive approach - create new state again
        state = AuthState(
          isLoading: false,
          user: null,
          error: null,
        );
        print('🔄 Final aggressive state reset');
        
        // Final verification
        final aggressiveState = state;
        print('📱 Final aggressive state:');
        print('  - User: ${aggressiveState.user?.name ?? 'null'}');
        print('  - User ID: ${aggressiveState.user?.id ?? 'null'}');
        
        if (aggressiveState.user == null) {
          print('✅ Aggressive logout successful');
        } else {
          print('❌ Even aggressive logout failed');
        }
      } else {
        print('✅ Forced logout successful - user cleared');
      }
      
    } catch (e) {
      print('❌ Error during forced logout: $e');
      // Even on error, try to clear the state
      state = AuthState(
        isLoading: false,
        user: null,
        error: e.toString(),
      );
    }
  }
  
  // Force refresh auth state from AuthService
  Future<void> forceRefreshAuthState() async {
    print('🔄 Force refreshing auth state...');
    
    try {
      // Get current state from AuthService
      final currentUser = AuthService.currentUser;
      final isAuthenticated = AuthService.isAuthenticated;
      
      print('🔍 AuthService current state:');
      print('  - Is Authenticated: $isAuthenticated');
      print('  - Current User: ${currentUser?.name ?? 'null'}');
      
      // Update provider state to match AuthService
      state = state.copyWith(
        user: currentUser,
        isLoading: false,
        error: null,
      );
      
      print('📱 Auth provider state updated:');
      print('  - User: ${state.user?.name ?? 'null'}');
      print('  - Is Loading: ${state.isLoading}');
      
    } catch (e) {
      print('❌ Error refreshing auth state: $e');
    }
  }
  
  // Force sync with AuthService (for debugging)
  Future<void> forceSyncWithAuthService() async {
    print('🔄 Force syncing with AuthService...');
    
    try {
      // Get current state from AuthService
      final currentUser = AuthService.currentUser;
      final isAuthenticated = AuthService.isAuthenticated;
      
      print('🔍 AuthService state:');
      print('  - Is Authenticated: $isAuthenticated');
      print('  - Current User: ${currentUser?.name ?? 'null'}');
      
      print('📱 Current provider state:');
      print('  - User: ${state.user?.name ?? 'null'}');
      print('  - Is Loading: ${state.isLoading}');
      
      // Update provider state to match AuthService
      state = state.copyWith(
        user: currentUser,
        isLoading: false,
        error: null,
      );
      
      print('✅ Provider state synced with AuthService');
      print('📱 Final provider state:');
      print('  - User: ${state.user?.name ?? 'null'}');
      print('  - Is Loading: ${state.isLoading}');
      
    } catch (e) {
      print('❌ Error syncing with AuthService: $e');
    }
  }
  
  // Completely reset auth state (nuclear option)
  void resetAuthState() {
    print('🔄 Nuclear reset of auth state...');
    
    // Create a completely fresh state
    state = const AuthState();
    
    print('✅ Auth state completely reset');
    print('📱 New state:');
    print('  - User: ${state.user?.name ?? 'null'}');
    print('  - Is Loading: ${state.isLoading}');
    print('  - Error: ${state.error ?? 'null'}');
  }
  
  // Aggressive force logout with nuclear reset
  Future<void> aggressiveForceLogout() async {
    print('🧨 === AGGRESSIVE FORCE LOGOUT ===');
    
    try {
      // Clear AuthService first
      await AuthService.clearUserData();
      print('✅ AuthService cleared');
      
      // Nuclear reset of provider state
      resetAuthState();
      
      // Verify both states are cleared
      final authServiceUser = AuthService.currentUser;
      final authServiceAuthenticated = AuthService.isAuthenticated;
      final providerUser = state.user;
      
      print('🔍 Verification after aggressive logout:');
      print('  - AuthService User: ${authServiceUser?.name ?? 'null'}');
      print('  - AuthService Authenticated: $authServiceAuthenticated');
      print('  - Provider User: ${providerUser?.name ?? 'null'}');
      
      if (authServiceUser == null && providerUser == null) {
        print('✅ Aggressive logout successful - both states cleared');
      } else {
        print('❌ Aggressive logout failed - states not cleared');
      }
      
    } catch (e) {
      print('❌ Error during aggressive logout: $e');
      // Even on error, reset the state
      resetAuthState();
    }
    
    print('🧨 === END AGGRESSIVE FORCE LOGOUT ===');
  }
} 