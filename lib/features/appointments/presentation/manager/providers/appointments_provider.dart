import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/core/network/api_client.dart';
import 'package:medical_follow_up_app/features/appointments/data/models/appointment_model.dart';
import 'package:medical_follow_up_app/features/appointments/data/network/appointment_api.dart';


final appointmentsApiProvider = Provider<AppointmentsApi>((ref) {
  final client = ApiClient();
  return AppointmentsApi(client);
});

final appointmentsProvider =
    FutureProvider<List<Appointment>>((ref) async {
  final api = ref.watch(appointmentsApiProvider);
  return api.getAppointments();
});
