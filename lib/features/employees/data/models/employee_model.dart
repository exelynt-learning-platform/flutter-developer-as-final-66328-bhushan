import '../../domain/entities/employee.dart';

class EmployeeModel extends Employee {
  const EmployeeModel({
    super.id,
    required super.name,
    required super.email,
    required super.mobile,
    required super.country,
    required super.state,
    required super.district,
    super.createdAt,
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

  factory EmployeeModel.fromEntity(Employee e) => EmployeeModel(
        id: e.id,
        name: e.name,
        email: e.email,
        mobile: e.mobile,
        country: e.country,
        state: e.state,
        district: e.district,
        createdAt: e.createdAt,
      );
}
