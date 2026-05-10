import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

/// A structured, UI-ready model for application errors.
///
/// Instead of throwing raw [Exception]s or [String]s, the app wraps every
/// error into a [Failure] object that carries three pieces of information:
///
/// 1. **[title]** – A short, human-readable headline (e.g. "Connection Error").
/// 2. **[message]** – A friendly, non-technical sentence explaining what happened
///    and what the user can do next.
/// 3. **[icon]** – A visual cue (a [FeatherIcons] icon) so the UI can display
///    an appropriate illustration without additional logic.
/// 4. **[code]** – An optional HTTP status code for logging/debugging purposes.
///
/// ### Factory Constructors
/// Each `factory` constructor is a pre-configured [Failure] for a specific
/// failure scenario. This pattern (called a *named factory*) keeps callers
/// clean — they write `Failure.network()` instead of repeating the title,
/// message, and icon everywhere.
///
/// ### Where is it used?
/// - [error_mapper.dart] translates raw [DioException]s into [Failure]s.
/// - [AuthNotifier], [ProfileNotifier], etc. catch exceptions and expose
///   `state.error` as a [Failure.message] to the UI.
/// - [ErrorView] widget renders a [Failure] on screen.
class Failure {
  /// The short headline shown in the error card title.
  final String title;

  /// The full, user-friendly description of what went wrong.
  final String message;

  /// A [FeatherIcons] icon that visually represents the failure type.
  final IconData icon;

  /// Optional HTTP status code, useful for debugging (e.g. "401", "404").
  final String? code;

  const Failure({
    required this.title,
    required this.message,
    required this.icon,
    this.code,
  });

  // ─────────────────────────────────────────────────
  // Named factory constructors for each failure type.
  // ─────────────────────────────────────────────────

  /// Created when the device cannot reach the server.
  ///
  /// Triggered by [DioExceptionType.connectionError],
  /// [DioExceptionType.connectionTimeout], etc.
  factory Failure.network() => const Failure(
        title: 'Connection Error',
        message:
            'We couldn\'t connect to our servers. Please check your internet connection and try again.',
        icon: FeatherIcons.wifiOff,
      );

  /// Created when the server returns a 5xx error or an unexpected response.
  ///
  /// [message] can be overridden with the specific backend message.
  /// [code] carries the HTTP status code for logging.
  factory Failure.server({String? message, String? code}) => Failure(
        title: 'Server Issue',
        message: message ??
            'Our servers are having a bit of trouble right now. We\'re working on it!',
        icon: FeatherIcons.server,
        code: code,
      );

  /// Created when the server returns a **401 Unauthorized** response.
  ///
  /// This signals an expired or invalid JWT. The app should prompt the user
  /// to log in again.
  factory Failure.auth() => const Failure(
        title: 'Session Expired',
        message: 'Your session has ended. Please log in again to continue.',
        icon: FeatherIcons.lock,
      );

  /// Created when the user provides wrong login credentials.
  ///
  /// Detected by [error_mapper.dart] when the backend message contains
  /// keywords like "invalid", "incorrect", or "credentials".
  factory Failure.invalidCredentials() => const Failure(
        title: 'Login Failed',
        message:
            'The email or password you entered is incorrect. Please check and try again.',
        icon: FeatherIcons.userX,
      );

  /// Created when the server returns a **404 Not Found** response.
  factory Failure.notFound() => const Failure(
        title: 'Not Found',
        message: 'The information you\'re looking for seems to be missing.',
        icon: FeatherIcons.search,
      );

  /// A catch-all factory for any error that doesn't fit the above categories.
  ///
  /// [message] can be provided from the raw exception's [toString()].
  factory Failure.unknown({String? message}) => Failure(
        title: 'Unexpected Error',
        message:
            message ?? 'Something went wrong on our end. Please try again later.',
        icon: FeatherIcons.alertCircle,
      );

  @override
  String toString() => 'Failure(title: $title, message: $message)';
}
