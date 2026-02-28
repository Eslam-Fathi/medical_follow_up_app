import 'package:dio/dio.dart';
import 'package:medical_follow_up_app/core/errors/error_mapper.dart';
import 'package:medical_follow_up_app/core/network/api_client.dart';

import 'package:medical_follow_up_app/features/appointments/data/models/appointment_model.dart';

class AppointmentsApi {
  final ApiClient _client;
  AppointmentsApi(this._client);

  Future<List<Appointment>> getAppointments() async {
    try {
      final res = await _client.dio.get('/api/appointments');
      final data = res.data as List<dynamic>;
      return data
          .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e, fallback: 'Failed to load appointments');
    } catch (_) {
      throw Exception('Failed to load appointments');
    }
  }
}
