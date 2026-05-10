import 'package:medical_follow_up_app/features/auth/data/models/login/login_response.dart';

/// An immutable snapshot of the authentication state at any given point in time.
///
/// ### Immutability and [copyWith]
/// In Riverpod's [StateNotifier] pattern, the state must be replaced (not mutated)
/// each time it changes. Instead of mutating fields, [AuthNotifier] creates a new
/// [AuthState] via [copyWith], which copies all current values but replaces only
/// the ones provided. This ensures that Riverpod can detect changes and trigger
/// UI rebuilds.
///
/// ### State machine
/// The [AuthState] models three mutually relevant pieces of information:
///
/// | Scenario                  | [isLoading] | [loginResponse]  | [error] |
/// |---------------------------|-------------|------------------|---------|
/// | Initial / logged out      | `false`     | `null`           | `null`  |
/// | Loading (login/register)  | `true`      | `null` (pending) | `null`  |
/// | Authenticated             | `false`     | `LoginResponse`  | `null`  |
/// | Failed login attempt      | `false`     | `null`           | `String`|
///
/// ### Who uses this?
/// - [LoginScreen] watches `state.isLoading` to disable the button and show
///   a spinner, and `state.error` to display an error banner.
/// - [MedME] (the root widget) listens to `state.loginResponse` to trigger
///   automatic navigation on logout.
/// - [StartPoint] reads `state.loginResponse` to decide where to navigate
///   after the splash screen.
class AuthState {
  /// Whether an authentication operation (login/register/checkAuth) is in progress.
  ///
  /// When `true`, the UI should disable form inputs and show a loading indicator.
  final bool isLoading;

  /// The response from the last successful login or registration.
  ///
  /// - `null` when the user is not authenticated (initial state, logged out).
  /// - Non-null when the user is successfully authenticated.
  ///   Access [LoginResponse.user] to get the user's name, role, etc.
  final LoginResponse? loginResponse;

  /// A user-facing error message from the last failed operation.
  ///
  /// - `null` when no error has occurred (or after clearing via `copyWith`).
  /// - Non-null after a failed login attempt, network error, etc.
  ///
  /// **Important:** The [copyWith] implementation explicitly sets [error]
  /// to `null` unless a new value is provided. This means clearing an error
  /// requires only `state.copyWith(error: null)`.
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.loginResponse,
    this.error,
  });

  /// Creates a copy of this [AuthState] with the given fields replaced.
  ///
  /// Fields not provided retain their current values. Note that [error] does
  /// **not** use the null-coalescing `??` operator — passing `error: null`
  /// explicitly clears any previous error message.
  AuthState copyWith({
    bool? isLoading,
    LoginResponse? loginResponse,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      loginResponse: loginResponse ?? this.loginResponse,
      // error intentionally does NOT use `?? this.error` so it can be cleared.
      error: error,
    );
  }
}
