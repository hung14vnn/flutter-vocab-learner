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
  String? _userApiKey;
  bool _isInitialized = false;

  User? get user => _user;
  AppUser? get appUser => _appUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;
  String? get userApiKey => _userApiKey;
  void setUserApiKey(String apiKey) {
    _userApiKey = apiKey;
    notifyListeners();
  }

  AuthProvider() {
    _initializeAuth();
  }

  // Public method to wait for initial authentication state
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // Wait for the first auth state change
    await _authService.authStateChanges.first;
    _isInitialized = true;
  }

  void _initializeAuth() {
    _authService.authStateChanges.listen((User? user) async {
      _user = user;
      if (user != null) {
        await _loadUserDocument(user.uid);
      } else {
        _appUser = null;
      }
      _isInitialized = true;
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

  Future<bool> pinQuickAction(String actionName) async {
    if (_appUser == null) return false;
    
    try {
      List<String> pinnedActions = List<String>.from(_appUser!.pinnedQuickActions ?? []);
      
      // Don't add if already pinned
      if (pinnedActions.contains(actionName)) return false;
      
      // Limit to 2 pinned actions
      if (pinnedActions.length >= 2) {
        return false;
      }
      
      pinnedActions.add(actionName);
      
      AppUser updatedUser = _appUser!.copyWith(
        pinnedQuickActions: pinnedActions,
      );
      
      await updateUserProfile(updatedUser);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to pin action: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> unpinQuickAction(String actionName) async {
    if (_appUser == null) return;
    
    try {
      List<String> pinnedActions = List<String>.from(_appUser!.pinnedQuickActions ?? []);
      
      // Remove the action from pinned list
      pinnedActions.remove(actionName);
      
      AppUser updatedUser = _appUser!.copyWith(
        pinnedQuickActions: pinnedActions,
      );
      
      await updateUserProfile(updatedUser);
    } catch (e) {
      _errorMessage = 'Failed to unpin action: $e';
      notifyListeners();
    }
  }

  bool isActionPinned(String actionName) {
    return _appUser?.pinnedQuickActions?.contains(actionName) ?? false;
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
