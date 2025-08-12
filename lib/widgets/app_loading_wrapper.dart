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

class _AppLoadingWrapperState extends State<AppLoadingWrapper>
    with TickerProviderStateMixin {
  bool _isInitialized = false;
  bool _showMainApp = false;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));
    
    _initializeApp();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Initialize auth provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final initializationFuture = authProvider.initialize();
    final minimumLoadingTime = Future.delayed(const Duration(milliseconds: 2000));
    
    await Future.wait([
      initializationFuture,
      minimumLoadingTime,
    ]);
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
        _showMainApp = true;
      });
      
      _scaleController.forward();
      
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        await _fadeController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_showMainApp)
            ScaleTransition(
              scale: _scaleAnimation,
              child: const AuthWrapper(),
            ),
          
          if (!_isInitialized || _fadeController.isAnimating)
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: const LoadingScreen(),
                );
              },
            ),
        ],
      ),
    );
  }
}
