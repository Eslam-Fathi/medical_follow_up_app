import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class Failure {
  final String title;
  final String message;
  final IconData icon;
  final String? code;

  const Failure({
    required this.title,
    required this.message,
    required this.icon,
    this.code,
  });

  factory Failure.network() => const Failure(
        title: 'Connection Error',
        message: 'We couldn\'t connect to our servers. Please check your internet connection and try again.',
        icon: FeatherIcons.wifiOff,
      );

  factory Failure.server({String? message, String? code}) => Failure(
        title: 'Server Issue',
        message: message ?? 'Our servers are having a bit of trouble right now. We\'re working on it!',
        icon: FeatherIcons.server,
        code: code,
      );

  factory Failure.auth() => const Failure(
        title: 'Session Expired',
        message: 'Your session has ended. Please log in again to continue.',
        icon: FeatherIcons.lock,
      );

  factory Failure.invalidCredentials() => const Failure(
        title: 'Login Failed',
        message: 'The email or password you entered is incorrect. Please check and try again.',
        icon: FeatherIcons.userX,
      );

  factory Failure.notFound() => const Failure(
        title: 'Not Found',
        message: 'The information you\'re looking for seems to be missing.',
        icon: FeatherIcons.search,
      );

  factory Failure.unknown({String? message}) => Failure(
        title: 'Unexpected Error',
        message: message ?? 'Something went wrong on our end. Please try again later.',
        icon: FeatherIcons.alertCircle,
      );

  @override
  String toString() => 'Failure(title: $title, message: $message)';
}
