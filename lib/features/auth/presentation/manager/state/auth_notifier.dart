
import 'package:flutter_riverpod/legacy.dart';

import 'package:medical_follow_up_app/features/auth/data/models/auth_api/auth_api.dart';
import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_state.dart';
import 'package:medical_follow_up_app/core/network/api_providers.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApi _authApi;

  AuthNotifier(this._authApi) : super(const AuthState());



Future<void> login(String email, String password) async {
  state = state.copyWith(isLoading: true, error: null);

  try {
    final LoginResponse res =
        await _authApi.login(email: email, password: password);

    // Save JWT so interceptors can use it
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', res.token);

    state = state.copyWith(isLoading: false, loginResponse: res);
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      error: e.toString(),
    );
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

    state = state.copyWith(isLoading: false, loginResponse: res);
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      error: e.toString(),
    );
  }
}

Future<void> logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');
  state = const AuthState();
}

}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final api = ref.watch(authApiProvider);
  return AuthNotifier(api);
});
