import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';

/// Immutable auth state used by Riverpod.
class AuthState {
  final bool isLoading;
  final LoginResponse? loginResponse;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.loginResponse,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    LoginResponse? loginResponse,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      loginResponse: loginResponse ?? this.loginResponse,
      error: error,
    );
  }
}
