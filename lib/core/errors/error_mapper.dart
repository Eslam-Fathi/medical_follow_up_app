import 'package:dio/dio.dart';

Exception mapDioError(
  DioException e, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  // Try backend { "message": "Invalid credentials" }
  if (e.response?.data is Map<String, dynamic>) {
    final data = e.response!.data as Map<String, dynamic>;
    final msg = data['message']?.toString();
    if (msg != null && msg.isNotEmpty) {
      return Exception(msg);
    }
  }

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return Exception('Connection timed out. Check your internet connection.');
    case DioExceptionType.connectionError:
      return Exception('No internet connection. Please try again.');
    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        return Exception('Your session has expired. Please log in again.');
      }
      return Exception('Server error ($statusCode). Please try later.');
    default:
      return Exception(fallback);
  }
}
