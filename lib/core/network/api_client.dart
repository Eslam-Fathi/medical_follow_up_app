// core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A singleton HTTP client that wraps [Dio] with pre-configured defaults
/// and an authentication interceptor.
///
/// ### Why a singleton?
/// Creating multiple [Dio] instances would waste memory and make it harder to
/// share interceptors (e.g. the auth token injector). The singleton pattern
/// ensures every API call in the entire app goes through the same client,
/// which is initialized exactly once via the private [ApiClient._internal]
/// constructor.
///
/// ### Responsibilities
/// 1. **Base URL** — All relative endpoint paths (e.g. `/api/auth/login`) are
///    automatically prepended with the production server URL.
/// 2. **Timeouts** — Consistent 10-second timeouts prevent requests from
///    hanging indefinitely on slow connections.
/// 3. **Default Headers** — Every request carries `Content-Type: application/json`
///    so the backend knows how to parse the request body.
/// 4. **Auth Interceptor** — Before each request is dispatched, the interceptor
///    reads the JWT from [SharedPreferences] and injects it as a
///    `Authorization: Bearer <token>` header. This means API classes
///    (e.g. [AuthApi], [PatientApi]) never need to manually add auth headers.
///
/// ### How to use
/// Access the singleton via the default factory constructor:
/// ```dart
/// final client = ApiClient();
/// final response = await client.dio.get('/api/profile');
/// ```
/// Or, preferably, inject it through Riverpod via [apiClientProvider].
class ApiClient {
  /// The base URL for all API requests.
  ///
  /// All API path strings in this project are relative (e.g. `/api/auth/login`).
  /// Dio automatically combines this base URL with the relative path.
  static const String baseUrl = 'https://medical-app-seven-kappa.vercel.app';

  /// The single instance of [ApiClient] shared across the entire app.
  static final ApiClient _instance = ApiClient._internal();

  /// Public factory that always returns the same [_instance].
  ///
  /// Calling `ApiClient()` anywhere in the app gives you the same pre-configured
  /// [Dio] client without re-initializing it.
  factory ApiClient() => _instance;

  /// The underlying [Dio] HTTP client.
  ///
  /// Exposed as a field (rather than a method) so callers can make requests
  /// with `client.dio.get(...)`, `client.dio.post(...)`, etc.
  late final Dio dio;

  /// Private constructor: initializes [Dio] and registers interceptors.
  ///
  /// This runs only once because the singleton pattern prevents multiple
  /// instances from being created.
  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        // Maximum time to wait for a connection to be established.
        connectTimeout: const Duration(seconds: 10),
        // Maximum time to wait for the server to send response data.
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // ── Auth Interceptor ───────────────────────────────────────────────────
    // This [InterceptorsWrapper.onRequest] callback fires before every request.
    // It reads the JWT stored by [AuthNotifier.login/register] from
    // [SharedPreferences] and attaches it to the `Authorization` header.
    //
    // If no token is found (e.g. the user is not logged in), the header is
    // simply not added — the request goes through without authentication,
    // which is correct for public endpoints like `/api/auth/login`.
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');

          if (token != null && token.isNotEmpty) {
            // Inject the Bearer token so the backend can identify the user.
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Call handler.next() to pass the (possibly modified) request
          // to the next interceptor or to Dio's actual send mechanism.
          handler.next(options);
        },
      ),
    );
  }
}
