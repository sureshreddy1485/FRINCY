import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService instance = AuthService._init();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LocalAuthentication _localAuth = LocalAuthentication();

  AuthService._init();

  // Firebase Authentication
  Future<UserModel?> signInWithEmailPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        return await _getUserModel(credential.user!);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<UserModel?> signUpWithEmailPassword(
    String email, 
    String password, 
    String name,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        final userModel = await _getUserModel(credential.user!);
        await DatabaseService.instance.createUser(userModel);
        return userModel;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<UserModel?> signInWithPhoneNumber(
    String phoneNumber,
    Function(String verificationId) onCodeSent,
  ) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw e;
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<UserModel?> verifyOTP(String verificationId, String otp) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        final userModel = await _getUserModel(userCredential.user!);
        
        // Check if user exists in database, if not create
        final existingUser = await DatabaseService.instance.getUser(userModel.id);
        if (existingUser == null) {
          await DatabaseService.instance.createUser(userModel);
        }
        
        return userModel;
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<UserModel> _getUserModel(User user) async {
    final existingUser = await DatabaseService.instance.getUser(user.uid);
    
    if (existingUser != null) {
      return existingUser.copyWith(
        lastLoginAt: DateTime.now(),
      );
    }
    
    return UserModel(
      id: user.uid,
      name: user.displayName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _clearLocalAuth();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // PIN Authentication
  Future<void> setPIN(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final hashedPin = _hashPIN(pin);
    await prefs.setString('user_pin', hashedPin);
    
    final user = getCurrentUser();
    if (user != null) {
      final userModel = await DatabaseService.instance.getUser(user.uid);
      if (userModel != null) {
        await DatabaseService.instance.updateUser(
          userModel.copyWith(isPinEnabled: true),
        );
      }
    }
  }

  Future<bool> verifyPIN(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedHash = prefs.getString('user_pin');
    if (storedHash == null) return false;
    
    return storedHash == _hashPIN(pin);
  }

  Future<bool> isPINEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_pin') != null;
  }

  String _hashPIN(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Biometric Authentication
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  Future<bool> authenticateWithBiometric() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  Future<void> enableBiometric() async {
    final user = getCurrentUser();
    if (user != null) {
      final userModel = await DatabaseService.instance.getUser(user.uid);
      if (userModel != null) {
        await DatabaseService.instance.updateUser(
          userModel.copyWith(isBiometricEnabled: true),
        );
      }
    }
  }

  Future<void> disableBiometric() async {
    final user = getCurrentUser();
    if (user != null) {
      final userModel = await DatabaseService.instance.getUser(user.uid);
      if (userModel != null) {
        await DatabaseService.instance.updateUser(
          userModel.copyWith(isBiometricEnabled: false),
        );
      }
    }
  }

  Future<bool> isBiometricEnabled() async {
    final user = getCurrentUser();
    if (user != null) {
      final userModel = await DatabaseService.instance.getUser(user.uid);
      return userModel?.isBiometricEnabled ?? false;
    }
    return false;
  }

  Future<void> _clearLocalAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_pin');
  }

  // Password Reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
