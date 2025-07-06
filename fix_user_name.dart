// Temporary script to fix user name references
// This will be used to replace all .name with .fullName in auth_providers.dart

// Replace all instances of:
// state.user?.name -> state.user?.fullName
// currentUser?.name -> currentUser?.fullName
// finalState.user?.name -> finalState.user?.fullName
// finalAuthServiceUser?.name -> finalAuthServiceUser?.fullName
// aggressiveState.user?.name -> aggressiveState.user?.fullName
// authServiceUser?.name -> authServiceUser?.fullName
// providerUser?.name -> providerUser?.fullName 