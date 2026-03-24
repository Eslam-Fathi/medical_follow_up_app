import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
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


class BookAppointmentState {
  final bool isLoading;
  final String? error;

  const BookAppointmentState({this.isLoading = false, this.error});

  BookAppointmentState copyWith({bool? isLoading, String? error}) {
    return BookAppointmentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class BookAppointmentNotifier extends StateNotifier<BookAppointmentState> {
  final AppointmentsApi _api;

  BookAppointmentNotifier(this._api) : super(const BookAppointmentState());

  Future<Appointment?> book({
    required String patientId,
    required String doctorId,
    required DateTime dateTime,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final body = CreateAppointmentRequest(
        patientId: patientId,
        doctorId: doctorId,
        date: dateTime,
      );
      final appointment = await _api.createAppointment(body);

      // optionally refresh list
      // ignore if you are using cached appointmentsProvider
      // ref.invalidate(appointmentsProvider); (needs Ref)

      state = state.copyWith(isLoading: false);
      return appointment;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }
  
}

final bookAppointmentProvider =
    StateNotifierProvider<BookAppointmentNotifier, BookAppointmentState>((ref) {
  final api = ref.watch(appointmentsApiProvider);
  return BookAppointmentNotifier(api);
});
