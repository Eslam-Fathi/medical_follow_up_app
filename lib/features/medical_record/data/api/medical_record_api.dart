import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/network/api_client.dart';

final medicalRecordApiProvider = Provider<MedicalRecordApi>((ref) {
  return MedicalRecordApi(ApiClient());
});

final patientRecordProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, patientId) async {
  if (patientId.isEmpty || patientId == '—') return {};
  final api = ref.watch(medicalRecordApiProvider);
  return api.getMedicalRecordByPatientId(patientId);
});


class MedicalRecordApi {
  final ApiClient _client;

  MedicalRecordApi(this._client);

  /// Creates or updates a medical record for a patient.
  Future<void> saveMedicalRecord(Map<String, dynamic> payload) async {
    try {
      await _client.dio.post('/api/medical-records', data: payload);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message ?? 'Failed to save medical record');
    }
  }

  /// Fetches the most recent medical record by patient document ID.
  ///
  /// The backend returns an array of records sorted newest-first.
  /// Returns the most recent record's map, or an empty map if none exists.
  /// Throws on network/server errors so callers can react appropriately.
  Future<Map<String, dynamic>> getMedicalRecordByPatientId(String patientId) async {
    final res = await _client.dio.get('/api/medical-records/patient/$patientId');
    final data = res.data;

    if (data is List) {
      // Backend returns array — newest record is first.
      if (data.isNotEmpty && data.first is Map) {
        return Map<String, dynamic>.from(data.first as Map);
      }
      return {};
    } else if (data is Map) {
      // Some endpoints wrap the record in {record: {...}} or {data: {...}}
      if (data.containsKey('record') && data['record'] is Map) {
        return Map<String, dynamic>.from(data['record'] as Map);
      } else if (data.containsKey('data') && data['data'] is Map) {
        return Map<String, dynamic>.from(data['data'] as Map);
      }
      return Map<String, dynamic>.from(data as Map);
    }
    return {};
  }
}
