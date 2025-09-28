import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learning_app/core/services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  late StreamSubscription<User?> _authStateSubscription;

  AuthStatus _status = AuthStatus.unknown;
  AuthStatus get status => _status;

  User? _currentUser;
  User? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthProvider({required AuthService authService})
    : _authService = authService {
    _authStateSubscription = _authService.authStateChanges.listen(
      _onAuthStateChanged,
    );
  }

  void clearError() {
    _errorMessage = null;
  }

  void _onAuthStateChanged(User? user) {
    _currentUser = user;
    _status = user == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await _performAuthAction(
      () => _authService.signInWithEmailAndPassword(email, password),
    );
  }

  Future<void> register(String email, String password) async {
    await _performAuthAction(
      () => _authService.registerUserWithEmailAndPassword(email, password),
    );
  }

  Future<void> logout() async {
    await _authService.signOut();
  }

  Future<void> _performAuthAction(
    Future<UserCredential> Function() action,
  ) async {
    _setLoading(true);
    _errorMessage = null;
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapFirebaseAuthException(e.code);
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan tidak terduga';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _mapFirebaseAuthException(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Email tidak ditemukan.';
      case 'wrong-password':
        return 'Password salah.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar.';
      case 'weak-password':
        return 'Password terlalu lemah.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'invalid-credential':
        return 'Email atau password salah.';
      default:
        return 'Terjadi kesalahan autentikasi.';
    }
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }
}
