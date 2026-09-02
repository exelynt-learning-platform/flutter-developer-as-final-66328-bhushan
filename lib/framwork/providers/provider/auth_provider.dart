import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/status_enum.dart';
import '../../repository/repository/auth_repository.dart';

final authProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends ChangeNotifier {
  final AuthRepository _repository;

  AuthNotifier({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  StatusEnum _status = StatusEnum.initial;
  String? _errorMessage;
  User? _user;

  StatusEnum get status => _status;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  bool get isLoading => _status == StatusEnum.loading;
  bool get isAuthenticated => _user != null;

  /// Call once on app start to listen to Firebase auth state
  void init() {
    _repository.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading();
    try {
      final credential = await _repository.signInWithEmail(email, password);
      _user = credential.user;
      _setSuccess();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> registerWithEmail(
      String email, String password, String displayName) async {
    _setLoading();
    try {
      final credential =
          await _repository.registerWithEmail(email, password, displayName);
      _user = credential.user;
      _setSuccess();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _setLoading();
    try {
      final credential = await _repository.signInWithGoogle();
      _user = credential.user;
      _setSuccess();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading();
    try {
      await _repository.sendPasswordResetEmail(email);
      _setSuccess();
      return true;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _user = null;
    _status = StatusEnum.initial;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _status = StatusEnum.initial;
    notifyListeners();
  }

  void _setLoading() {
    _status = StatusEnum.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = StatusEnum.success;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = StatusEnum.error;
    _errorMessage = message;
    notifyListeners();
  }
}
