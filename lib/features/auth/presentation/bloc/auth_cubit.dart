import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  final SignInUseCase _signIn;
  final RegisterUseCase _register;
  final GoogleSignInUseCase _googleSignIn;
  final ResetPasswordUseCase _resetPassword;
  final SignOutUseCase _signOut;

  AuthCubit({
    required AuthRepository repository,
    required SignInUseCase signInUseCase,
    required RegisterUseCase registerUseCase,
    required GoogleSignInUseCase googleUseCase,
    required ResetPasswordUseCase resetUseCase,
    required SignOutUseCase signOutUseCase,
  })  : _repository = repository,
        _signIn = signInUseCase,
        _register = registerUseCase,
        _googleSignIn = googleUseCase,
        _resetPassword = resetUseCase,
        _signOut = signOutUseCase,
        super(const AuthInitial()) {
    _repository.authStateChanges.listen((user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    emit(const AuthLoading());
    try {
      final user = await _signIn(email, password);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> registerWithEmail(
      String email, String password, String displayName) async {
    emit(const AuthLoading());
    try {
      final user = await _register(email, password, displayName);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    try {
      final user = await _googleSignIn();
      if (user == null) {
        emit(const AuthGoogleCancelled());
      } else {
        emit(Authenticated(user));
      }
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    emit(const AuthLoading());
    try {
      await _resetPassword(email);
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> signOut() async {
    await _signOut();
    emit(const Unauthenticated());
  }

  void clearError() {
    emit(const Unauthenticated());
  }
}
