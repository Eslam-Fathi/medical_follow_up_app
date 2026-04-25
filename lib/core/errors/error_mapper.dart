import 'package:dio/dio.dart';
import 'failure.dart';

Failure mapDioError(
  DioException e, {
  String? fallback,
}) {
  // Try backend { "message": "Invalid credentials" }
  if (e.response?.data is Map<String, dynamic>) {
    final data = e.response!.data as Map<String, dynamic>;
    final msg = data['message']?.toString();
    if (msg != null && msg.isNotEmpty) {
      final lowercaseMsg = msg.toLowerCase();
      if (lowercaseMsg.contains('invalid') || 
          lowercaseMsg.contains('incorrect') || 
          lowercaseMsg.contains('credentials')) {
        return Failure.invalidCredentials();
      }
      return Failure.server(message: msg, code: e.response?.statusCode?.toString());
    }
  }

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return Failure.network();
    case DioExceptionType.connectionError:
      return Failure.network();
    case DioExceptionType.badResponse:
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        return Failure.auth();
      }
      if (statusCode == 404) {
        return Failure.notFound();
      }
      return Failure.server(
        message: 'Server error ($statusCode). Please try later.',
        code: statusCode?.toString(),
      );
    default:
      return Failure.unknown(message: fallback);
  }
}

Failure mapError(Object e) {
  if (e is DioException) {
    return mapDioError(e);
  }
  if (e is Failure) {
    return e;
  }
  return Failure.unknown(message: e.toString());
}
