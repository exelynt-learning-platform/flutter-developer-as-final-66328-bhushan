import 'dart:convert';

List<CountryModel> countryListFromJson(String str) =>
    List<CountryModel>.from(
        json.decode(str).map((x) => CountryModel.fromJson(x)));

class CountryModel {
  final String? id;
  final String name; // mapped from 'country' field in API
  final String? flag;
  final String? createdAt;

  CountryModel({
    this.id,
    required this.name,
    this.flag,
    this.createdAt,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) => CountryModel(
        id: json['id']?.toString(),
        // API returns 'country', not 'name'
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
