import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/features/auth/data/models/auth_api/auth_api.dart';
import 'api_client.dart';
import 'package:medical_follow_up_app/features/profile/data/api/patient_api.dart';
import 'package:medical_follow_up_app/features/doctors/data/api/doctor_api.dart';
import 'package:medical_follow_up_app/features/appointments/data/api/appointment_api.dart';


/// Provides a singleton ApiClient instance.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provides AuthApi, which uses ApiClient internally.
final authApiProvider = Provider<AuthApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthApi(client);
});

/// Provides PatientApi
final patientApiProvider = Provider<PatientApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return PatientApi(client);
});

/// Provides DoctorApi
final doctorApiProvider = Provider<DoctorApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return DoctorApi(client);
});

/// Provides AppointmentApi
final appointmentApiProvider = Provider<AppointmentApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return AppointmentApi(client);
});
