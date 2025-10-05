import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final firebaseUser = AuthService.instance.getCurrentUser();
      if (firebaseUser != null) {
        _currentUser = await DatabaseService.instance.getUser(firebaseUser.uid);
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await AuthService.instance.signInWithEmailPassword(email, password);
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUpWithEmail(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await AuthService.instance.signUpWithEmailPassword(email, password, name);
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signInWithPhone(
    String phoneNumber,
    Function(String verificationId) onCodeSent,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await AuthService.instance.signInWithPhoneNumber(phoneNumber, onCodeSent);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> verifyOTP(String verificationId, String otp) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await AuthService.instance.verifyOTP(verificationId, otp);
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> authenticateWithPIN(String pin) async {
    return await AuthService.instance.verifyPIN(pin);
  }

  Future<void> setPIN(String pin) async {
    await AuthService.instance.setPIN(pin);
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(isPinEnabled: true);
      notifyListeners();
    }
  }

  Future<bool> authenticateWithBiometric() async {
    return await AuthService.instance.authenticateWithBiometric();
  }

  Future<void> enableBiometric() async {
    await AuthService.instance.enableBiometric();
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(isBiometricEnabled: true);
      notifyListeners();
    }
  }

  Future<void> disableBiometric() async {
    await AuthService.instance.disableBiometric();
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(isBiometricEnabled: false);
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await AuthService.instance.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> updateUserProfile(UserModel updatedUser) async {
    await DatabaseService.instance.updateUser(updatedUser);
    _currentUser = updatedUser;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
