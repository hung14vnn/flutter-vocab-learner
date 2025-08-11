import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth_wrapper.dart';
import 'loading_screen.dart';

class AppLoadingWrapper extends StatefulWidget {
  const AppLoadingWrapper({super.key});

  @override
  State<AppLoadingWrapper> createState() => _AppLoadingWrapperState();
}

class _AppLoadingWrapperState extends State<AppLoadingWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Add a minimum loading time to show the loading screen
    final initializationFuture = authProvider.initialize();
    final minimumLoadingTime = Future.delayed(const Duration(milliseconds: 2000));
    
    // Wait for both initialization and minimum loading time
    await Future.wait([
      initializationFuture,
      minimumLoadingTime,
    ]);
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const LoadingScreen();
    }
    
    return const AuthWrapper();
  }
}
