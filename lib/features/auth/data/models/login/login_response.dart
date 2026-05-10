/// Data Transfer Object (DTO) representing the user fields returned
/// in the login and registration API responses.
///
/// ### What is a DTO?
/// A DTO (Data Transfer Object) is a plain class whose sole purpose is to
/// carry data from one layer to another — in this case, from the JSON response
/// body to Dart code. It has no business logic.
///
/// ### Fields from the API
/// The backend returns a `user` object inside both `/api/auth/login` and
/// `/api/auth/register` responses. This class maps those JSON fields:
///
/// ```json
/// {
///   "_id":   "64f1a2b3c4d5e6f708090a0b",
///   "name":  "John Doe",
///   "email": "john@example.com",
///   "role":  "PATIENT"
/// }
/// ```
///
/// **Note on `_id` vs `id`:** MongoDB uses `_id` as the primary key name.
/// The [fromJson] factory remaps `_id` to the Dart-idiomatic `id` field.
///
/// ### Role values
/// The `role` field determines what the user can do:
/// - `"PATIENT"` — Standard patient account. Can book appointments, view records.
/// - `"DOCTOR"` — Doctor account. Can manage appointments and patient lists.
/// - `"SUPER_ADMIN"` — Admin account. Has access to the admin dashboard.
class UserDto {
  /// The user's unique MongoDB document ID.
  final String id;

  /// The user's full display name.
  final String name;

  /// The user's email address (used as login credential).
  final String email;

  /// The user's role string. One of `"PATIENT"`, `"DOCTOR"`, `"SUPER_ADMIN"`.
  final String role;

  UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  /// Constructs a [UserDto] from a JSON map.
  ///
  /// Maps the MongoDB `_id` field to the Dart `id` property and casts all
  /// other fields to [String].
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }
}

/// Represents the full response body from the `/api/auth/login` and
/// `/api/auth/register` endpoints.
///
/// ### Backend response structure
/// ```json
/// {
///   "message": "Login successful",
///   "token":   "<JWT string>",
///   "user": {
///     "_id":   "...",
///     "name":  "...",
///     "email": "...",
///     "role":  "PATIENT"
///   }
/// }
/// ```
///
/// ### Token usage
/// The [token] is a **JSON Web Token (JWT)**. It must be:
/// 1. Persisted to [SharedPreferences] by [AuthNotifier] after login.
/// 2. Injected into every subsequent API request by [ApiClient]'s auth
///    interceptor as `Authorization: Bearer <token>`.
///
/// This class is the single source of truth for the authenticated user's
/// basic profile. More detailed profile data (patient/doctor info) is fetched
/// separately via [profileProvider].
class LoginResponse {
  /// A server-provided status message (e.g. "Login successful").
  ///
  /// Not typically shown in the UI, but useful for debugging.
  final String message;

  /// The JWT access token. Store securely and attach to all API requests.
  final String token;

  /// The logged-in user's basic identity information.
  final UserDto user;

  LoginResponse({
    required this.message,
    required this.token,
    required this.user,
  });

  /// Constructs a [LoginResponse] from the raw JSON map returned by the server.
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] as String,
      token: json['token'] as String,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
