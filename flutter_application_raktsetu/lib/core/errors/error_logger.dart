import 'package:flutter/foundation.dart';

class ErrorLogger {
  static void logError(Object error, StackTrace? stackTrace) {
    if (kDebugMode) {
      print('🔴 Error: $error');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    } else {
      // TODO: Send to Crashlytics or Sentry in production
      // FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  }

  static void logMessage(String message) {
    if (kDebugMode) {
      print('🔵 Log: $message');
    }
  }
}
