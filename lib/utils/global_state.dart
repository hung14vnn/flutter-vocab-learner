import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// Utility class for easy access to global state throughout the app
class GlobalState {
  /// Get the current user ID from anywhere in the app
  /// Returns null if user is not authenticated
  static String? getUserId(BuildContext context) {
    try {
      return Provider.of<AuthProvider>(context, listen: false).userId;
    } catch (e) {
      // Return null if context is not available or provider is not found
      return null;
    }
  }

  /// Get the current user ID with listening to changes
  /// This will rebuild the widget when userId changes
  static String? getUserIdWithListener(BuildContext context) {
    try {
      return Provider.of<AuthProvider>(context, listen: true).userId;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is authenticated from anywhere in the app
  static bool isAuthenticated(BuildContext context) {
    try {
      return Provider.of<AuthProvider>(context, listen: false).isAuthenticated;
    } catch (e) {
      return false;
    }
  }

  /// Get the AuthProvider instance for more complex operations
  static AuthProvider getAuthProvider(BuildContext context, {bool listen = false}) {
    return Provider.of<AuthProvider>(context, listen: listen);
  }

  /// Extension method to make context usage even cleaner
}

/// Extension on BuildContext for even cleaner access
extension GlobalStateExtension on BuildContext {
  /// Get current user ID
  String? get userId => GlobalState.getUserId(this);
  
  /// Get current user ID with listener
  String? get userIdWithListener => GlobalState.getUserIdWithListener(this);
  
  /// Check if user is authenticated
  bool get isAuthenticated => GlobalState.isAuthenticated(this);
  
  /// Get AuthProvider
  AuthProvider get authProvider => GlobalState.getAuthProvider(this);
  
  /// Get AuthProvider with listener
  AuthProvider get authProviderWithListener => GlobalState.getAuthProvider(this, listen: true);
}
