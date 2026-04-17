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

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApi _authApi;
  final Ref _ref;

  AuthNotifier(this._authApi, this._ref) : super(const AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final LoginResponse res = await _authApi.login(
        email: email,
        password: password,
      );

      // Save JWT so interceptors can use it
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', res.token);
      await prefs.setString('user_id', res.user.id);
      await prefs.setString('user_name', res.user.name);
      await prefs.setString('user_email', res.user.email);
      await prefs.setString('user_role', res.user.role);

      state = state.copyWith(isLoading: false, loginResponse: res);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

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
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');

    // Clear local care team
    await _ref.read(careTeamProvider.notifier).clear();

    // Reset core data providers
    _ref.invalidate(profileProvider);
    _ref.invalidate(appointmentsProvider);
    _ref.invalidate(doctorAppointmentsProvider);

    state = const AuthState();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final id = prefs.getString('user_id');
      final name = prefs.getString('user_name');
      final email = prefs.getString('user_email');
      final role = prefs.getString('user_role');

      if (token != null &&
          id != null &&
          name != null &&
          email != null &&
          role != null) {
        final res = LoginResponse(
          message: 'Auto login',
          token: token,
          user: UserDto(id: id, name: name, email: email, role: role),
        );
        state = state.copyWith(isLoading: false, loginResponse: res);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final api = ref.watch(authApiProvider);
  return AuthNotifier(api, ref);
});
