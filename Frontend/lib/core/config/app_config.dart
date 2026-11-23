import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class AppConfig {
  /// Base host detection:
  /// - Android Emulator uses 10.0.2.2
  /// - iOS Simulator, Web, Desktop (Windows/macOS/Linux) uses localhost
  static String get defaultHost {
    if (kIsWeb) return 'http://localhost:3000';
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000';
      } else if (Platform.isIOS) {
        return 'http://localhost:3000';
      }
    } catch (_) {
      // Platform check fallback
    }
    return 'http://localhost:3000';
  }

  /// Override URL at compile/run time using:
  /// `flutter run --dart-define=API_URL=http://192.168.1.10:3000`
  static const String _overrideUrl = String.fromEnvironment('API_URL');

  static String get serverBaseUrl =>
      _overrideUrl.isNotEmpty ? _overrideUrl : defaultHost;

  static String get groupsUrl => '$serverBaseUrl/groups';
  static String get expensesUrl => '$serverBaseUrl/expenses';
}
