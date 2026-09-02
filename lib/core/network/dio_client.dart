import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: const Duration(seconds: kConnectTimeoutSeconds),
        receiveTimeout: const Duration(seconds: kReceiveTimeoutSeconds),
        sendTimeout: const Duration(seconds: kConnectTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.next(options),
        onResponse: (response, handler) => handler.next(response),
        onError: (error, handler) => handler.next(error),
      ),
    );
  }

  Future<dynamic> get(String path) async {
    try {
      final response = await dio.get(path);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(String path, Map<String, dynamic> data) async {
    try {
      final response = await dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> put(String path, Map<String, dynamic> data) async {
    try {
      final response = await dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await dio.delete(path);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  AppFailure _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppFailure(
            'Connection timed out. Please check your internet connection.');
      case DioExceptionType.connectionError:
        return const AppFailure(
            'No internet connection. Please try again.');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 404) return const AppFailure('Resource not found.');
        if (code == 500) {
          return const AppFailure('Server error. Please try again later.');
        }
        return AppFailure('Server responded with error $code.');
      default:
        return const AppFailure('Something went wrong. Please try again.');
    }
  }
}
