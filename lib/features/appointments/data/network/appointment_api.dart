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

  Future<List<Appointment>> getTodayReminders() async {
    try {
      final res = await _client.dio.get('/api/appointments/today-reminders');
      final rawData = res.data;
      
      List<dynamic> targetList;
      if (rawData is List) {
        targetList = rawData;
      } else if (rawData is Map) {
        // Fallback for wrapped responses
        if (rawData.containsKey('data') && rawData['data'] is List) {
          targetList = rawData['data'] as List<dynamic>;
        } else if (rawData.containsKey('reminders') && rawData['reminders'] is List) {
          targetList = rawData['reminders'] as List<dynamic>;
        } else {
          targetList = [];
        }
      } else {
        targetList = [];
      }

      return targetList
          .map((e) => Appointment.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw mapDioError(e, fallback: 'Failed to load today reminders');
    } catch (e) {
      throw Exception('Data Parse Error: $e');
    }
  }

  //! implemented and need refactor
  //TODO: create a separate request model for creating appointment

  Future<Appointment> createAppointment(CreateAppointmentRequest body) async {
    try {
      final res = await _client.dio.post(
        '/api/appointments',
        data: body.toJson(),
      );
      final rawData = res.data;
      final payload = rawData is Map && rawData.containsKey('appointment') 
          ? rawData['appointment'] 
          : rawData;
      return Appointment.fromJson(payload as Map<String, dynamic>);
    } on DioException catch (e) {
      throw mapDioError(e, fallback: 'Failed to create appointment');
    } catch (e) {
      throw Exception('Parse error: $e');
    }
  }

  Future<void> updateAppointmentStatus(String id, String status, DateTime date) async {
    try {
      await _client.dio.put(
        '/api/appointments/$id',
        data: {
          'status': status,
          'date': date.toUtc().toIso8601String(),
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e, fallback: 'Failed to update appointment');
    } catch (_) {
      throw Exception('Failed to update appointment');
    }
  }
}

