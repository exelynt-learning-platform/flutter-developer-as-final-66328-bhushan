/// Abstract contract defining all API operations used in this app.
abstract class ApiContract {
  Future<dynamic> get(String url);
  Future<dynamic> post(String url, Map<String, dynamic> data);
  Future<dynamic> put(String url, Map<String, dynamic> data);
  Future<dynamic> delete(String url);
}
