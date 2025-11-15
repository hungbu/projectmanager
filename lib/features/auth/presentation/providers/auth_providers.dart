import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/auth_service.dart';
import '../../domain/entities/user.dart';

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

      } else {
        state = state.copyWith(isLoading: false);

      }
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);

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
      final user = await AuthService.getMe();
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

    try {
      // Clear auth data without API call
      await AuthService.clearUserData();
      
      // Verify AuthService state
      final isAuthenticated = AuthService.isAuthenticated;
      final currentUser = AuthService.currentUser;

      // Create a completely new state object to force update
      final newState = AuthState(
        isLoading: false,
        user: null,
        error: null,
      );
      
      // Update state with new object
      state = newState;

      // Verify the state was updated

      // Add a small delay to ensure state is updated
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Force another state update with explicit null
      state = state.copyWith(user: null);

      // Verify final state
      final finalState = state;

      // Double-check AuthService state
      final finalAuthServiceUser = AuthService.currentUser;
      final finalAuthServiceAuthenticated = AuthService.isAuthenticated;

      // Verify the state is actually null
      if (finalState.user != null) {

        // Try one more aggressive approach - create new state again
        state = AuthState(
          isLoading: false,
          user: null,
          error: null,
        );

        // Final verification
        final aggressiveState = state;

        if (aggressiveState.user == null) {

        } else {

        }
      } else {

      }
      
    } catch (e) {

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

    try {
      // Get current state from AuthService
      final currentUser = AuthService.currentUser;
      final isAuthenticated = AuthService.isAuthenticated;

      // Update provider state to match AuthService
      state = state.copyWith(
        user: currentUser,
        isLoading: false,
        error: null,
      );

    } catch (e) {

    }
  }
  
  // Force sync with AuthService (for debugging)
  Future<void> forceSyncWithAuthService() async {

    try {
      // Get current state from AuthService
      final currentUser = AuthService.currentUser;
      final isAuthenticated = AuthService.isAuthenticated;

      // Update provider state to match AuthService
      state = state.copyWith(
        user: currentUser,
        isLoading: false,
        error: null,
      );

    } catch (e) {

    }
  }
  
  // Completely reset auth state (nuclear option)
  void resetAuthState() {

    // Create a completely fresh state
    state = const AuthState();

  }
  
  // Aggressive force logout with nuclear reset
  Future<void> aggressiveForceLogout() async {

    try {
      // Clear AuthService first
      await AuthService.clearUserData();

      // Nuclear reset of provider state
      resetAuthState();
      
      // Verify both states are cleared
      final authServiceUser = AuthService.currentUser;
      final authServiceAuthenticated = AuthService.isAuthenticated;
      final providerUser = state.user;

      if (authServiceUser == null && providerUser == null) {

      } else {

      }
      
    } catch (e) {

      // Even on error, reset the state
      resetAuthState();
    }

  }
} 