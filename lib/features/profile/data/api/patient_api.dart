import 'package:dio/dio.dart';
import 'package:medical_follow_up_app/core/network/api_client.dart';

class PatientApi {
  final ApiClient _client;

  PatientApi(this._client);

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
      await _client.dio.post('/api/patients', data: {
        "userId": userId,
        "displayId": displayId,
        "age": age,
        "gender": gender,
        "bloodType": bloodType,
        "chronicDiseases": chronicDiseases,
        "allergies": allergies,
        "notes": notes,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}
