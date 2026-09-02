import 'dart:convert';

List<EmployeeModel> employeeListFromJson(String str) =>
    List<EmployeeModel>.from(json.decode(str).map((x) => EmployeeModel.fromJson(x)));

String employeeListToJson(List<EmployeeModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

EmployeeModel employeeFromJson(String str) => EmployeeModel.fromJson(json.decode(str));

String employeeToJson(EmployeeModel data) => json.encode(data.toJson());

class EmployeeModel {
  final String? id;
  final String name;
  final String email;
  final String mobile;
  final String country;
  final String state;
  final String district;
  final String? createdAt;

  EmployeeModel({
    this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.country,
    required this.state,
    required this.district,
    this.createdAt,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) => EmployeeModel(
        id: json['id']?.toString(),
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        mobile: json['mobile'] ?? json['phone'] ?? '',
        country: json['country'] ?? '',
        state: json['state'] ?? '',
        district: json['district'] ?? '',
        createdAt: json['createdAt']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'email': email,
        'mobile': mobile,
        'country': country,
        'state': state,
        'district': district,
        if (createdAt != null) 'createdAt': createdAt,
      };

  EmployeeModel copyWith({
    String? id,
    String? name,
    String? email,
    String? mobile,
    String? country,
    String? state,
    String? district,
    String? createdAt,
  }) =>
      EmployeeModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        mobile: mobile ?? this.mobile,
        country: country ?? this.country,
        state: state ?? this.state,
        district: district ?? this.district,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
