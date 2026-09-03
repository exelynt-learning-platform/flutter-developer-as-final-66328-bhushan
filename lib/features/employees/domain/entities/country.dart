import 'package:equatable/equatable.dart';

class Country extends Equatable {
  final String? id;
  final String name;
  final String? flag;
  final String? createdAt;

  const Country({
    this.id,
    required this.name,
    this.flag,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, name];
}
