import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:medical_follow_up_app/features/auth/data/models/auth_api/auth_api.dart';
import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_state.dart';
import 'package:medical_follow_up_app/core/network/api_providers.dart';
import 'package:medical_follow_up_app/features/profile/presentation/manager/profile.provider.dart';
import 'package:medical_follow_up_app/features/appointments/presentation/manager/providers/appointments_provider.dart';
import 'package:medical_follow_up_app/features/doctors/presentation/manager/care_team_provider.dart';
import 'package:medical_follow_up_app/core/errors/error_mapper.dart';

/// The state manager (business logic controller) for authentication.
///
/// ### What is a StateNotifier?
/// [StateNotifier] is a Riverpod class for managing mutable state. Each method
/// modifies [state] (an [AuthState]) by calling [state = state.copyWith(...)],
/// which is immutable — a new [AuthState] object is created rather than
/// modifying the existing one. This triggers Riverpod to rebuild any widget
/// that watches [authNotifierProvider].
///
/// ### Responsibilities
/// 1. **[login]** — Calls [AuthApi.login], stores the JWT and user info in
///    [SharedPreferences], and updates the state to `authenticated`.
/// 2. **[register]** — Same flow as [login] but calls [AuthApi.register].
/// 3. **[logout]** — Clears all auth data from [SharedPreferences], resets the
///    state to initial (unauthenticated), and clears related providers.
/// 4. **[checkAuthStatus]** — Called at app startup. Reads any persisted token
///    and user info from [SharedPreferences] to restore session without a
///    network call.
///
/// ### Token persistence strategy
/// After a successful login/register, the JWT and basic user fields are written
/// to [SharedPreferences] (a key-value store backed by Android's SharedPreferences
/// and iOS's NSUserDefaults). On the next app launch, [checkAuthStatus] reads
/// these values and reconstructs a [LoginResponse] in memory, skipping a full
/// re-login as long as the token is still valid.
///
/// ### Why store `user_id`, `user_name`, etc. separately?
/// JWTs can be decoded to extract claims, but that requires a JSON decoding
/// library and adds complexity. Storing the user fields explicitly in
/// [SharedPreferences] is simpler and fast to read.
class AuthNotifier extends StateNotifier<AuthState> {
  /// The data layer class that talks to the auth API.
  final AuthApi _authApi;

  /// A [Ref] reference to the Riverpod container, used to interact with
  /// other providers (e.g. invalidating [profileProvider] on logout).
  final Ref _ref;

  /// Initializes with an empty (unauthenticated) [AuthState].
  AuthNotifier(this._authApi, this._ref) : super(const AuthState());

  // ────────────────────────────────────────────────────────────────────────────
  // LOGIN
  // ────────────────────────────────────────────────────────────────────────────

  /// Authenticates the user with [email] and [password].
  ///
  /// **Flow:**
  /// 1. Sets [AuthState.isLoading] to `true` and clears any previous error.
  /// 2. Calls [AuthApi.login] to send credentials to the server.
  /// 3. On success: persists the JWT + user fields to [SharedPreferences] and
  ///    sets the state to authenticated.
  /// 4. On failure: sets [AuthState.error] with a user-friendly message.
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final LoginResponse res = await _authApi.login(
        email: email,
        password: password,
      );

      // ── Persist token and user info for future sessions ──────────────────
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', res.token);
      await prefs.setString('user_id', res.user.id);
      await prefs.setString('user_name', res.user.name);
      await prefs.setString('user_email', res.user.email);
      await prefs.setString('user_role', res.user.role);

      // Update state → triggers all listeners (e.g. LoginScreen, MedME).
      state = state.copyWith(isLoading: false, loginResponse: res);
    } catch (e) {
      // mapError converts DioException → Failure and extracts its message.
      state = state.copyWith(isLoading: false, error: mapError(e).message);
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // REGISTER
  // ────────────────────────────────────────────────────────────────────────────

  /// Registers a new user account and logs them in automatically.
  ///
  /// The [role] parameter determines the account type. Defaults to `"PATIENT"`.
  /// Supported values: `"PATIENT"`, `"DOCTOR"`.
  ///
  /// The flow is identical to [login] except it calls [AuthApi.register].
  Future<void> register({
    required String name,
    required String email,
    required String password,
    String role = 'PATIENT',
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final LoginResponse res = await _authApi.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', res.token);
      await prefs.setString('user_id', res.user.id);
      await prefs.setString('user_name', res.user.name);
      await prefs.setString('user_email', res.user.email);
      await prefs.setString('user_role', res.user.role);

      state = state.copyWith(isLoading: false, loginResponse: res);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: mapError(e).message);
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // LOGOUT
  // ────────────────────────────────────────────────────────────────────────────

  /// Clears all authentication data and resets the state to unauthenticated.
  ///
  /// **Why set state first?**
  /// Setting [state] to an empty [AuthState] immediately makes all watching
  /// widgets react to the logout (e.g. the [MedME] listener in main.dart
  /// sees `loginResponse == null` and navigates to `/auth`). The
  /// SharedPreferences cleanup happens concurrently and is fire-and-forget
  /// from the UI's perspective.
  ///
  /// **Care team cleanup:**
  /// [careTeamProvider] stores a list of doctors associated with the patient.
  /// It is explicitly cleared here because it holds user-specific data that
  /// must not leak between accounts.
  Future<void> logout() async {
    // Reset state immediately so listeners react without waiting for disk I/O.
    state = const AuthState();

    final prefs = await SharedPreferences.getInstance();

    // Run all cleanup operations in parallel for performance.
    await Future.wait([
      prefs.remove('auth_token'),
      prefs.remove('user_id'),
      prefs.remove('user_name'),
      prefs.remove('user_email'),
      prefs.remove('user_role'),
      // Clear care team cache manually since it doesn't auto-reset.
      _ref.read(careTeamProvider.notifier).clear(),
    ]);

    // Note: profileProvider and appointmentsProvider auto-reset because they
    // internally watch authNotifierProvider. When loginResponse becomes null,
    // they re-evaluate and return an error/empty state automatically.
  }

  // ────────────────────────────────────────────────────────────────────────────
  // CHECK AUTH STATUS (App Launch)
  // ────────────────────────────────────────────────────────────────────────────

  /// Checks if a valid session exists in [SharedPreferences] on app startup.
  ///
  /// Called by [StartPoint] immediately after the app launches. If a stored
  /// token and user info are found, a synthetic [LoginResponse] is constructed
  /// in memory — this avoids a network round-trip just to verify identity.
  ///
  /// **Important:** This does **not** validate the token with the server. If
  /// the token has expired server-side, the first API call (e.g. [profileProvider])
  /// will fail with a 401 and [StartPoint] will call [logout] to clean up.
  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final id = prefs.getString('user_id');
      final name = prefs.getString('user_name');
      final email = prefs.getString('user_email');
      final role = prefs.getString('user_role');

      // Only restore the session if ALL required fields are present.
      if (token != null &&
          id != null &&
          name != null &&
          email != null &&
          role != null) {
        // Reconstruct a LoginResponse from persisted data without a network call.
        final res = LoginResponse(
          message: 'Auto login',
          token: token,
          user: UserDto(id: id, name: name, email: email, role: role),
        );
        state = state.copyWith(isLoading: false, loginResponse: res);
      } else {
        // No valid session found — user must log in.
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: mapError(e).message);
    }
  }
}

/// The Riverpod provider that exposes [AuthNotifier] and its [AuthState].
///
/// This is a [StateNotifierProvider], meaning widgets can both:
/// - **Watch** the state: `ref.watch(authNotifierProvider)` → [AuthState]
/// - **Call** methods: `ref.read(authNotifierProvider.notifier).login(...)`
///
/// The provider injects [AuthApi] from [authApiProvider], ensuring the notifier
/// uses the same pre-configured HTTP client as the rest of the app.
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final api = ref.watch(authApiProvider);
  return AuthNotifier(api, ref);
});
