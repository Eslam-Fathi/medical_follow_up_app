import 'package:dio/dio.dart';
import 'package:medical_follow_up_app/core/network/api_client.dart';
import 'package:medical_follow_up_app/features/doctors/data/models/doctor_model/doctor_model.dart';

class DoctorApi {
  final ApiClient _client;

  DoctorApi(this._client);

  Future<void> createDoctorProfile({
    required String userId,
    required String specialization,
    required String licenseNumber,
    required int yearsOfExperience,
  }) async {
    try {
      await _client.dio.post('/api/doctors', data: {
        "userId": userId,
        "specialization": specialization,
        "licenseNumber": licenseNumber,
        "yearsOfExperience": yearsOfExperience,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<List<dynamic>> getPendingDoctors() async {
    try {
      final res = await _client.dio.get('/api/doctors/pending');
      if (res.data is List) {
        return res.data as List<dynamic>;
      } else if (res.data['data'] is List) {
        return res.data['data'] as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<void> updateDoctorStatus(String doctorId, String status) async {
    try {
      await _client.dio.patch('/api/doctors/$doctorId/status', data: {
        "status": status,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  Future<List<DoctorModel>> getAllDoctors() async {
    try {
      final res = await _client.dio.get('/api/doctors');
      List<dynamic> rawList = [];
      if (res.data is List) {
        rawList = res.data;
      } else if (res.data['data'] is List) {
        rawList = res.data['data'];
      }
      return rawList.map((doc) => DoctorModel.fromJson(doc as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}
