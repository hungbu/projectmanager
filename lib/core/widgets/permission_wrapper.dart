import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/permission_service.dart';

class PermissionWrapper extends ConsumerWidget {
  final Widget child;
  final String permission;
  final Widget? fallback;

  const PermissionWrapper({
    super.key,
    required this.child,
    required this.permission,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasPermission = PermissionService.hasPermission(permission);
    
    if (hasPermission) {
      return child;
    } else if (fallback != null) {
      return fallback!;
    } else {
      return const SizedBox.shrink();
    }
  }
}

class AdminOnly extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const AdminOnly({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = PermissionService.isAdmin();
    
    if (isAdmin) {
      return child;
    } else if (fallback != null) {
      return fallback!;
    } else {
      return const SizedBox.shrink();
    }
  }
}

class PartnerOnly extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const PartnerOnly({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPartner = PermissionService.isPartner();
    
    if (isPartner) {
      return child;
    } else if (fallback != null) {
      return fallback!;
    } else {
      return const SizedBox.shrink();
    }
  }
}

class UserOnly extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const UserOnly({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUser = PermissionService.isUser();
    
    if (isUser) {
      return child;
    } else if (fallback != null) {
      return fallback!;
    } else {
      return const SizedBox.shrink();
    }
  }
}

class CanEditProject extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const CanEditProject({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canEdit = PermissionService.canEditProject();
    
    if (canEdit) {
      return child;
    } else if (fallback != null) {
      return fallback!;
    } else {
      return const SizedBox.shrink();
    }
  }
}

class CanDeleteProject extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const CanDeleteProject({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canDelete = PermissionService.canDeleteProject();
    
    if (canDelete) {
      return child;
    } else if (fallback != null) {
      return fallback!;
    } else {
      return const SizedBox.shrink();
    }
  }
}

class CanCreateProject extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const CanCreateProject({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canCreate = PermissionService.canCreateProject();
    
    if (canCreate) {
      return child;
    } else if (fallback != null) {
      return fallback!;
    } else {
      return const SizedBox.shrink();
    }
  }
}

class CanEditTask extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const CanEditTask({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canEdit = PermissionService.canEditTask();
    
    if (canEdit) {
      return child;
    } else if (fallback != null) {
      return fallback!;
    } else {
      return const SizedBox.shrink();
    }
  }
}

class CanDeleteTask extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const CanDeleteTask({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canDelete = PermissionService.canDeleteTask();
    
    if (canDelete) {
      return child;
    } else if (fallback != null) {
      return fallback!;
    } else {
      return const SizedBox.shrink();
    }
  }
}

class CanCreateTask extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const CanCreateTask({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canCreate = PermissionService.canCreateTask();
    
    if (canCreate) {
      return child;
    } else if (fallback != null) {
      return fallback!;
    } else {
      return const SizedBox.shrink();
    }
  }
}

class CanUpdateTaskStatus extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const CanUpdateTaskStatus({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canUpdate = PermissionService.canUpdateTaskStatus();
    
    if (canUpdate) {
      return child;
    } else if (fallback != null) {
      return fallback!;
    } else {
      return const SizedBox.shrink();
    }
  }
}

class CanManageUsers extends ConsumerWidget {
  final Widget child;
  final Widget? fallback;

  const CanManageUsers({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canManage = PermissionService.canManageUsers();
    
    if (canManage) {
      return child;
    } else if (fallback != null) {
      return fallback!;
    } else {
      return const SizedBox.shrink();
    }
  }
} 