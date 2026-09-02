import 'package:dio/dio.dart';
import '../../utils/app_constants.dart';

Dio getDio() {
  final options = BaseOptions(
    baseUrl: kBaseUrl,
    connectTimeout: const Duration(seconds: kConnectTimeoutSeconds),
    receiveTimeout: const Duration(seconds: kReceiveTimeoutSeconds),
    sendTimeout: const Duration(seconds: kConnectTimeoutSeconds),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  );

  final dio = Dio(options);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
        return handler.next(options);
      },
      onResponse: (Response response, ResponseInterceptorHandler handler) {
        return handler.next(response);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) {
        return handler.next(error);
      },
    ),
  );

  return dio;
}
