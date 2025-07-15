import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/progress_provider.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          // Initialize progress provider when user is authenticated
          final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
          progressProvider.initializeForUser(authProvider.user!.uid);
          
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
