import 'dart:convert';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../models/employee_model.dart';

class EmployeeRemoteDataSource {
  final DioClient _client;
  const EmployeeRemoteDataSource(this._client);

  Future<List<EmployeeModel>> getAll() async {
    final response = await _client.get(kEmployeeEndpoint);
    return (response as List)
        .map((e) => EmployeeModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<EmployeeModel> getById(String id) async {
    final response =
        await _client.get('$kEmployeeEndpoint/$id');
    return EmployeeModel.fromJson(
        Map<String, dynamic>.from(response as Map));
  }

  Future<EmployeeModel> create(EmployeeModel employee) async {
    final response =
        await _client.post(kEmployeeEndpoint, employee.toJson());
    return EmployeeModel.fromJson(
        Map<String, dynamic>.from(response as Map));
  }

  Future<EmployeeModel> update(EmployeeModel employee) async {
    final response = await _client.put(
        '$kEmployeeEndpoint/${employee.id}', employee.toJson());
    return EmployeeModel.fromJson(
        Map<String, dynamic>.from(response as Map));
  }

  Future<void> delete(String id) =>
      _client.delete('$kEmployeeEndpoint/$id');
}

// helpers for Hive JSON cache
String employeeListToJson(List<EmployeeModel> list) =>
    jsonEncode(list.map((e) => e.toJson()).toList());

List<EmployeeModel> employeeListFromJson(String str) =>
    (jsonDecode(str) as List)
        .map((e) => EmployeeModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
