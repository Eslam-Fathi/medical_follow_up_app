import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medical_follow_up_app/features/auth/data/models/auth_api/auth_api.dart';
import 'api_client.dart';
import 'package:medical_follow_up_app/features/profile/data/api/patient_api.dart';
import 'package:medical_follow_up_app/features/doctors/data/api/doctor_api.dart';
import 'package:medical_follow_up_app/features/appointments/data/api/appointment_api.dart';

/// Central registry of Riverpod providers for all API service classes.
///
/// ### Architecture role
/// This file sits at the boundary between the **network layer** (Dio + [ApiClient])
/// and the **data layer** (feature-specific API classes like [AuthApi]).
///
/// By declaring API services as Riverpod [Provider]s here, we achieve:
/// - **Dependency injection** — Any notifier or widget can access an API class
///   via `ref.watch(authApiProvider)` without having to construct it manually.
/// - **Testability** — In tests, providers can be overridden to return mock
///   implementations (`ProviderScope(overrides: [authApiProvider.overrideWith(...)])`).
/// - **Single source of truth** — There is exactly one [ApiClient] instance in
///   the entire app (it is itself a singleton), and exactly one instance of
///   each API service that wraps it.
///
/// ### Dependency graph
/// ```
/// apiClientProvider
///   ├── authApiProvider
///   ├── patientApiProvider
///   ├── doctorApiProvider
///   └── appointmentApiProvider
/// ```
/// Each feature-level provider [ref.watch]s [apiClientProvider], so if the
/// client is ever replaced (e.g. for testing), all API providers update too.

/// Provides a singleton [ApiClient] instance to the Riverpod graph.
///
/// [ApiClient] is itself a Dart singleton (via its `factory` constructor), so
/// this provider always returns the same underlying object. Declaring it as a
/// provider makes it injectable and overridable in tests.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provides [AuthApi], which handles login and registration requests.
///
/// [AuthApi] depends on [ApiClient] for the pre-configured Dio instance.
/// Watching [apiClientProvider] here means that if the client changes in a test,
/// this provider automatically provides a new [AuthApi] backed by the new client.
final authApiProvider = Provider<AuthApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return AuthApi(client);
});

/// Provides [PatientApi], which handles patient profile CRUD operations.
final patientApiProvider = Provider<PatientApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return PatientApi(client);
});

/// Provides [DoctorApi], which handles doctor search, approval, and profile
/// data fetching.
final doctorApiProvider = Provider<DoctorApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return DoctorApi(client);
});

/// Provides [AppointmentApi], which handles fetching, creating, and updating
/// appointment records.
final appointmentApiProvider = Provider<AppointmentApi>((ref) {
  final client = ref.watch(apiClientProvider);
  return AppointmentApi(client);
});
