import 'package:dio/dio.dart';
import 'package:medical_follow_up_app/core/errors/error_mapper.dart';
import 'package:medical_follow_up_app/core/network/api_client.dart';
import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';

/// Strongly-typed wrapper for the `/api/auth/profile` response.
///
/// The backend returns:
/// {
///   "user": { ... },
///   "patient": { ... } | null,
///   "doctor": { ... } | null
/// }
class ProfileResponse {
  /// Authenticated user info (always present).
  final UserDto user;

  /// Optional patient profile data if this user has a patient record.
  final Map<String, dynamic>? patient;

  /// Optional doctor profile data if this user has a doctor record.
  final Map<String, dynamic>? doctor;

  ProfileResponse({required this.user, this.patient, this.doctor});

  /// Creates a [ProfileResponse] from raw JSON returned by the API.
  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
      patient: json['patient'] as Map<String, dynamic>?,
      doctor: json['doctor'] as Map<String, dynamic>?,
    );
  }
}

/// API service for fetching profile data for the currently
/// authenticated user.
///
/// Uses the shared [ApiClient] (with auth token, base URL, interceptors).
class ProfileApi {
  final ApiClient _client;

  ProfileApi(this._client);

  /// Calls `GET /api/auth/profile` and parses the response.
  ///
  /// On success: returns a [ProfileResponse] containing user + optional
  /// patient/doctor objects.
  ///
  /// On error: maps Dio errors to user-friendly messages using [mapDioError].
  Future<ProfileResponse> getProfile() async {
    try {
      final res = await _client.dio.get('/api/auth/profile');
      return ProfileResponse.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // Convert low-level Dio error into app-specific exception.
      throw mapDioError(e, fallback: 'Failed to load profile');
    } catch (_) {
      // Fallback for any unexpected error type.
      throw Exception('Failed to load profile');
    }
  }
}
