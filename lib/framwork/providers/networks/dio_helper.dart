import 'package:dio/dio.dart';
import '../../../framwork/repository/contract/api_contract.dart';
import 'get_dio.dart';

class DioHelper implements ApiContract {
  final Dio dio;

  DioHelper({Dio? dioClient}) : dio = dioClient ?? getDio();

  @override
  Future<dynamic> get(String url) async {
    try {
      final response = await dio.get(url);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> post(String url, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(url, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> put(String url, Map<String, dynamic> data) async {
    try {
      final response = await dio.put(url, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<dynamic> delete(String url) async {
    try {
      final response = await dio.delete(url);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timed out. Please check your internet connection.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) return Exception('Resource not found.');
        if (statusCode == 500) return Exception('Server error. Please try again later.');
        return Exception('Server responded with error $statusCode.');
      default:
        return Exception('Something went wrong. Please try again.');
    }
  }
}
