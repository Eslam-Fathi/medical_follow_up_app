import 'package:dio/dio.dart';
import 'package:medical_follow_up_app/core/network/api_client.dart';

class AppointmentApi {
  final ApiClient _client;

  AppointmentApi(this._client);

  Future<void> createAppointment({
    required String patientId,
    required String doctorId,
    required String date,
    required String status,
  }) async {
    try {
      await _client.dio.post('/api/appointments', data: {
        "patientId": patientId,
        "doctorId": doctorId,
        "date": date,
        "status": status,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}
