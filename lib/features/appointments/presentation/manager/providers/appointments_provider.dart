import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:medical_follow_up_app/core/network/api_client.dart';
import 'package:medical_follow_up_app/features/appointments/data/models/appointment_model.dart';
import 'package:medical_follow_up_app/features/appointments/data/network/appointment_api.dart';
import 'package:medical_follow_up_app/features/profile/presentation/manager/profile.provider.dart';
import 'package:medical_follow_up_app/features/auth/presentation/manager/state/auth_notifier.dart';


final appointmentsApiProvider = Provider<AppointmentsApi>((ref) {
  final client = ApiClient();
  return AppointmentsApi(client);
});

final appointmentsProvider =
    FutureProvider<List<Appointment>>((ref) async {
  // Watch auth state to ensure this provider re-runs on logout/login
  final authState = ref.watch(authNotifierProvider);

  if (authState.loginResponse == null) {
     return []; // Return empty list when not logged in
  }

  final api = ref.watch(appointmentsApiProvider);
  return api.getAppointments();
});

final doctorAvailabilityProvider =
    FutureProvider.family<List<Appointment>, String>((ref, doctorId) async {
  final api = ref.watch(appointmentsApiProvider);
  return api.getAppointments(doctorId: doctorId);
});

final doctorAppointmentsProvider =
    FutureProvider<List<Appointment>>((ref) async {
  // Watch auth state to ensure this provider re-runs on logout/login
  final authState = ref.watch(authNotifierProvider);
  
  if (authState.loginResponse == null) {
     return []; // Return empty list when not logged in
  }
  
  final appointments = await ref.watch(appointmentsProvider.future);
  final profileAsync = await ref.watch(profileProvider.future);
  
  final doctorUserId = profileAsync.user.id;

  // Filter for appointments where the doctor is the current user
  return appointments.where((app) => app.doctor.user.id == doctorUserId).toList();
});

final todayRemindersProvider =
    FutureProvider<List<Appointment>>((ref) async {
  final api = ref.watch(appointmentsApiProvider);
  return api.getTodayReminders();
});

final nextAppointmentProvider = FutureProvider<Appointment?>((ref) async {
  final appointments = await ref.watch(appointmentsProvider.future);
  if (appointments.isEmpty) return null;

  final now = DateTime.now();
  // Filter for future appointments that aren't completed/cancelled
  final upcoming = appointments.where((app) {
    return app.date.isAfter(now) && 
           (app.status.toUpperCase() == 'PENDING' || app.status.toUpperCase() == 'CONFIRMED');
  }).toList();

  if (upcoming.isEmpty) return null;
  
  // Sort by date ascending to get the closest one
  upcoming.sort((a, b) => a.date.compareTo(b.date));
  return upcoming.first;
});

final upcomingRemindersProvider =
    FutureProvider<List<Appointment>>((ref) async {
  final appointments = await ref.watch(appointmentsProvider.future);
  if (appointments.isEmpty) return [];

  final now = DateTime.now();
  final nextWeek = now.add(const Duration(days: 7));
  
  // Filter for future appointments within the next 7 days that aren't completed/cancelled
  final upcoming = appointments.where((app) {
    return app.date.isAfter(now) && 
           app.date.isBefore(nextWeek) &&
           (app.status.toUpperCase() == 'PENDING' || app.status.toUpperCase() == 'CONFIRMED');
  }).toList();

  return upcoming;
});


final homeFilterProvider = StateProvider<int>((ref) => 0);

final filteredDashboardAppointmentsProvider = FutureProvider<List<Appointment>>((ref) async {
  final appointments = await ref.watch(appointmentsProvider.future);
  final filterIndex = ref.watch(homeFilterProvider);
  final now = DateTime.now();

  if (appointments.isEmpty) return [];

  switch (filterIndex) {
    case 1: // Upcoming
      return appointments.where((app) {
        return (app.status.toUpperCase() == 'PENDING' || app.status.toUpperCase() == 'CONFIRMED') &&
               app.date.isAfter(now) &&
               !app.isMissed;
      }).toList();
    case 2: // Missed
      return appointments.where((app) => app.isMissed).toList();
    case 3: // Completed
      return appointments.where((app) => app.status.toUpperCase() == 'COMPLETED').toList();
    default: // All
      return appointments;
  }
});

final filteredDoctorAppointmentsProvider = FutureProvider<List<Appointment>>((ref) async {
  final appointments = await ref.watch(doctorAppointmentsProvider.future);
  final filterIndex = ref.watch(homeFilterProvider);
  final now = DateTime.now();

  if (appointments.isEmpty) return [];

  switch (filterIndex) {
    case 1: // Upcoming
      return appointments.where((app) {
        return (app.status.toUpperCase() == 'PENDING' || app.status.toUpperCase() == 'CONFIRMED') &&
               app.date.isAfter(now) &&
               !app.isMissed;
      }).toList();
    case 2: // Missed
      return appointments.where((app) => app.isMissed).toList();
    case 3: // Completed
      return appointments.where((app) => app.status.toUpperCase() == 'COMPLETED').toList();
    default: // All
      return appointments;
  }
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
  final Ref _ref;

  BookAppointmentNotifier(this._api, this._ref) : super(const BookAppointmentState());

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

      // Refresh appointments list so the UI updates immediately
      _ref.invalidate(appointmentsProvider);
      _ref.invalidate(todayRemindersProvider);

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
  return BookAppointmentNotifier(api, ref);
});
