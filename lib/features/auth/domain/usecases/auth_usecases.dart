import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository _repo;
  const SignInUseCase(this._repo);
  Future<AuthUser> call(String email, String password) =>
      _repo.signInWithEmail(email, password);
}

class RegisterUseCase {
  final AuthRepository _repo;
  const RegisterUseCase(this._repo);
  Future<AuthUser> call(String email, String password, String displayName) =>
      _repo.registerWithEmail(email, password, displayName);
}

class GoogleSignInUseCase {
  final AuthRepository _repo;
  const GoogleSignInUseCase(this._repo);
  Future<AuthUser?> call() => _repo.signInWithGoogle();
}

class ResetPasswordUseCase {
  final AuthRepository _repo;
  const ResetPasswordUseCase(this._repo);
  Future<void> call(String email) => _repo.sendPasswordResetEmail(email);
}

class SignOutUseCase {
  final AuthRepository _repo;
  const SignOutUseCase(this._repo);
  Future<void> call() => _repo.signOut();
}
