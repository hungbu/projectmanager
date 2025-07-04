import 'package:flutter/material.dart';

import '../services/navigation_service.dart';

class ContextWrapper extends StatefulWidget {
  final Widget child;

  const ContextWrapper({
    super.key,
    required this.child,
  });

  @override
  State<ContextWrapper> createState() => _ContextWrapperState();
}

class _ContextWrapperState extends State<ContextWrapper> {
  @override
  void initState() {
    super.initState();
    // Set current context when widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NavigationService.setCurrentContext(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Update context on every build to ensure it's always current
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NavigationService.setCurrentContext(context);
    });
    
    return ScaffoldMessenger(
      child: widget.child,
    );
  }
} 