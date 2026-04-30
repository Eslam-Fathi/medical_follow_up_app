import 'package:dio/dio.dart';
import 'package:medical_follow_up_app/core/network/api_client.dart';

/// API client for patient-related endpoints.
///
/// Currently only supports creating a patient profile that is linked
/// to an existing authenticated user (via `userId`).
class PatientApi {
  final ApiClient _client;

  PatientApi(this._client);

  /// Creates a new patient profile for the given [userId].
  ///
  /// Sends a POST to `/api/patients` with:
  /// - `userId`: backend user primary key (from auth)
  /// - `displayId`: human-readable ID (e.g. "P-0001")
  /// - `age`, `gender`, `bloodType`
  /// - `chronicDiseases`, `allergies`: string lists
  /// - `notes`: free-text additional information
  ///
  /// Throws an [Exception] with a backend-provided message (if present)
  /// when the request fails.
  Future<void> createPatientProfile({
    required String userId,
    required String displayId,
    required int age,
    required String gender,
    required String bloodType,
    required List<String> chronicDiseases,
    required List<String> allergies,
    required String notes,
  }) async {
    try {
      await _client.dio.post(
        '/api/patients',
        data: {
          "userId": userId,
          "displayId": displayId,
          "age": age,
          "gender": gender,
          "bloodType": bloodType,
          "chronicDiseases": chronicDiseases,
          "allergies": allergies,
          "notes": notes,
        },
      );
    } on DioException catch (e) {
      // Surface a readable error message, preferring the backend "message"
      // field if it exists, otherwise falling back to Dio's own message.
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}
