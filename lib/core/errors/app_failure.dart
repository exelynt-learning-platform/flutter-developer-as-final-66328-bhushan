import 'package:equatable/equatable.dart';

class AppFailure extends Equatable implements Exception {
  final String message;
  const AppFailure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => message;
}
