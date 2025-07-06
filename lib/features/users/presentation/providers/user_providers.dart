import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/user_repository.dart';
import '../../domain/entities/user.dart';
import '../../../../core/constants/user_roles.dart';

// User state notifier
class UserStateNotifier extends StateNotifier<AsyncValue<List<User>>> {
  final UserRepository _userRepository;

  UserStateNotifier(this._userRepository) : super(const AsyncValue.loading());

  // Load all users
  Future<void> loadUsers() async {
    state = const AsyncValue.loading();
    try {
      final users = await _userRepository.getAllUsers();
      state = AsyncValue.data(users);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Create new user
  Future<void> createUser({
    required String email,
    required String fullName,
    required String password,
    required String passwordConfirmation,
    required UserRole role,
  }) async {
    try {
      await _userRepository.createUser(
        email: email,
        fullName: fullName,
        password: password,
        passwordConfirmation: passwordConfirmation,
        role: role,
      );
      // Reload users after creating
      await loadUsers();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Update user
  Future<void> updateUser({
    required String userId,
    String? email,
    String? fullName,
    UserRole? role,
    bool? isActive,
  }) async {
    try {
      await _userRepository.updateUser(
        userId: userId,
        email: email,
        fullName: fullName,
        role: role,
        isActive: isActive,
      );
      // Reload users after updating
      await loadUsers();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _userRepository.deleteUser(userId);
      // Reload users after deleting
      await loadUsers();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Toggle user status
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _userRepository.toggleUserStatus(userId, isActive);
      // Reload users after toggling
      await loadUsers();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Providers
final userStateProvider = StateNotifierProvider<UserStateNotifier, AsyncValue<List<User>>>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return UserStateNotifier(userRepository);
});

// Filtered users provider
final filteredUsersProvider = Provider<AsyncValue<List<User>>>((ref) {
  final usersState = ref.watch(userStateProvider);
  return usersState.when(
    data: (users) => AsyncValue.data(users),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
}); 