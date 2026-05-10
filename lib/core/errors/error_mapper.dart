import 'package:dio/dio.dart';
import 'failure.dart';

/// Translates raw [DioException]s (and generic [Object]s) into structured
/// [Failure] objects that the rest of the app can display and reason about.
///
/// ### Why a mapper?
/// Network libraries like Dio throw low-level exceptions that contain HTTP
/// status codes, raw response bodies, and internal enum types. Surfacing those
/// directly to the UI would be brittle and unfriendly. This mapper acts as a
/// **translation layer** that converts every possible Dio error into one of
/// the pre-defined [Failure] factory values, keeping UI code ignorant of the
/// HTTP layer.
///
/// ### Usage pattern
/// ```dart
/// try {
///   final result = await dio.get('/endpoint');
/// } on DioException catch (e) {
///   throw mapDioError(e, fallback: 'Could not load data.');
/// } catch (e) {
///   throw mapError(e); // handles non-Dio errors too
/// }
/// ```

/// Maps a [DioException] to the most appropriate [Failure].
///
/// **Resolution order:**
/// 1. If the response body contains a `"message"` key that looks like a
///    credential error (e.g. "Invalid credentials"), return [Failure.invalidCredentials].
/// 2. If the response body contains any other `"message"`, wrap it in
///    [Failure.server] so the backend's explanation is shown to the user.
/// 3. Fall back to the [DioExceptionType] switch:
///    - Timeout / Connection errors → [Failure.network]
///    - 401 → [Failure.auth]
///    - 404 → [Failure.notFound]
///    - Other bad responses → [Failure.server] with the status code.
///    - Anything else → [Failure.unknown] with [fallback] as the message.
///
/// Parameters:
/// - [e]        The original [DioException] thrown by Dio.
/// - [fallback] Optional message used when no other context is available.
Failure mapDioError(
  DioException e, {
  String? fallback,
}) {
  // ── Step 1: Inspect the backend's response body ───────────────────────────
  // Many REST APIs return a JSON body like { "message": "Invalid credentials" }
  // even on error responses. We check for this first because it provides the
  // most specific user-facing message.
  if (e.response?.data is Map<String, dynamic>) {
    final data = e.response!.data as Map<String, dynamic>;
    final msg = data['message']?.toString();
    if (msg != null && msg.isNotEmpty) {
      final lowercaseMsg = msg.toLowerCase();
      // Detect credential-related errors by keyword matching.
      if (lowercaseMsg.contains('invalid') ||
          lowercaseMsg.contains('incorrect') ||
          lowercaseMsg.contains('credentials')) {
        return Failure.invalidCredentials();
      }
      // Return the backend's message verbatim for other server errors.
      return Failure.server(
          message: msg, code: e.response?.statusCode?.toString());
    }
  }

  // ── Step 2: Fall back to the DioExceptionType ─────────────────────────────
  // When there's no helpful body, we switch on the type of Dio error.
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      // Any of the three timeout types mean the connection is too slow / lost.
      return Failure.network();
    case DioExceptionType.connectionError:
      // Completely failed to establish a connection (offline, DNS failure, etc.)
      return Failure.network();
    case DioExceptionType.badResponse:
      // The server responded, but with an error status code.
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        // 401 = Unauthorized. The JWT is expired or missing.
        return Failure.auth();
      }
      if (statusCode == 404) {
        // 404 = Not Found. The resource doesn't exist on the server.
        return Failure.notFound();
      }
      // Any other 4xx/5xx falls through to a generic server error.
      return Failure.server(
        message: 'Server error ($statusCode). Please try later.',
        code: statusCode?.toString(),
      );
    default:
      // Unknown Dio error types (e.g. request cancellation).
      return Failure.unknown(message: fallback);
  }
}

/// A general-purpose error mapper that handles both [DioException]s and
/// any other [Object] that might be thrown.
///
/// This is the top-level function that callers should use in `catch` blocks
/// when they don't know the specific exception type ahead of time.
///
/// - If [e] is a [DioException], it delegates to [mapDioError].
/// - If [e] is already a [Failure], it is returned unchanged (no double-wrapping).
/// - Otherwise, a [Failure.unknown] is created with the exception's `toString()`.
Failure mapError(Object e) {
  if (e is DioException) {
    return mapDioError(e);
  }
  if (e is Failure) {
    // Already mapped — avoid wrapping a Failure in another Failure.
    return e;
  }
  return Failure.unknown(message: e.toString());
}
