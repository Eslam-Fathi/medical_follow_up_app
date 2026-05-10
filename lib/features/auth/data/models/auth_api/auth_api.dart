import 'package:dio/dio.dart';
import 'package:medical_follow_up_app/core/errors/error_mapper.dart';
import 'package:medical_follow_up_app/core/network/api_client.dart';
import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';

/// The low-level data layer for authentication operations.
///
/// ### Responsibilities
/// This class is the **only** place in the app that communicates with the
/// backend's `/api/auth` endpoints. It knows the exact URL paths, the expected
/// request body shape, and how to parse the response JSON into Dart objects.
///
/// ### Separation of concerns
/// [AuthApi] knows nothing about:
/// - Riverpod state or providers.
/// - SharedPreferences / token storage.
/// - Flutter widgets or navigation.
///
/// All of that is handled by [AuthNotifier], which calls [AuthApi] and then
/// manages the resulting state. This separation makes [AuthApi] independently
/// testable and reusable.
///
/// ### Error handling
/// All network errors ([DioException]) are translated into [Failure] objects
/// via [mapDioError] before being re-thrown. This means callers (e.g.
/// [AuthNotifier]) always receive a typed [Failure] and never have to inspect
/// raw Dio exceptions.
class AuthApi {
  /// The pre-configured [ApiClient] that provides the [Dio] instance.
  ///
  /// Injected via the constructor so it can be mocked in tests.
  final ApiClient _client;

  AuthApi(this._client);

  /// Authenticates an existing user by email and password.
  ///
  /// **Endpoint:** `POST /api/auth/login`
  ///
  /// **Request body:**
  /// ```json
  /// { "email": "user@example.com", "password": "secret123" }
  /// ```
  ///
  /// **Success:** Returns a [LoginResponse] containing the JWT token and
  /// the user's basic profile data ([UserDto]).
  ///
  /// **Failure:** Throws a [Failure] (translated from the raw [DioException]
  /// via [mapDioError]).
  ///
  /// Parameters:
  /// - [email]    The user's registered email address.
  /// - [password] The user's plaintext password (sent over HTTPS only).
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _client.dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      // Parse the response body into a strongly-typed Dart object.
      return LoginResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // Convert the Dio-level error to a user-friendly Failure and re-throw.
      throw mapDioError(e, fallback: 'Login failed. Please try again.');
    } catch (_) {
      // Catch any other unexpected error (e.g. JSON parsing failure).
      throw Exception('Login failed. Please try again.');
    }
  }

  /// Registers a new user account.
  ///
  /// **Endpoint:** `POST /api/auth/register`
  ///
  /// **Request body:**
  /// ```json
  /// {
  ///   "name":     "John Doe",
  ///   "email":    "john@example.com",
  ///   "password": "secret123",
  ///   "role":     "PATIENT"
  /// }
  /// ```
  ///
  /// **Success:** Returns a [LoginResponse] — the same shape as login, because
  /// a successful registration automatically logs the user in (the server issues
  /// a JWT immediately upon registration).
  ///
  /// **Failure:** Throws a [Failure].
  ///
  /// Parameters:
  /// - [name]     The user's display name.
  /// - [email]    The desired email address (must be unique on the server).
  /// - [password] The desired password.
  /// - [role]     The account type: `"PATIENT"`, `"DOCTOR"`, or `"SUPER_ADMIN"`.
  Future<LoginResponse> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final res = await _client.dio.post(
        '/api/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );
      return LoginResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e, fallback: 'Registration failed. Please try again.');
    } catch (_) {
      throw Exception('Registration failed. Please try again.');
    }
  }
}
