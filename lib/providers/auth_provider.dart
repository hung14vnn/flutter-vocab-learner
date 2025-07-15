import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  AppUser? _appUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        await _loadUserDocument(user.uid);
      } else {
        _appUser = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserDocument(String userId) async {
    try {
      _appUser = await _authService.getUserDocument(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load user data: $e';
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String email, String password, String displayName) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.registerWithEmailAndPassword(email, password, displayName);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
    } catch (e) {
      _errorMessage = 'Failed to sign out: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserProfile(AppUser updatedUser) async {
    try {
      await _authService.updateUserDocument(updatedUser);
      _appUser = updatedUser;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      notifyListeners();
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
