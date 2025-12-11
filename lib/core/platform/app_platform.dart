import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class AppPlatform {
  static bool get isWeb => kIsWeb;

  // Note: on web, Platform is not available, so guard with kIsWeb
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isMobile => isAndroid || isIOS;

  static bool get isDesktop =>
      !kIsWeb &&
      (Platform.isMacOS || Platform.isWindows || Platform.isLinux);
}
