import '../../domain/entities/country.dart';

class CountryModel extends Country {
  const CountryModel({
    super.id,
    required super.name,
    super.flag,
    super.createdAt,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
        id: json['id']?.toString(),
        name: (json['country'] ?? json['name'] ?? '').toString(),
        flag: json['flag']?.toString(),
        createdAt: json['createdAt']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'country': name,
        if (flag != null) 'flag': flag,
        if (createdAt != null) 'createdAt': createdAt,
      };
}
