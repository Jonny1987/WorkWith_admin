import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/exceptions/app_exceptions.dart';

class Logger {
  void logError(Object error, StackTrace? stackTrace) {
    // * This can be replaced with a call to a crash reporting tool of choice
    debugPrint('$error, $stackTrace');
  }

  void logAppException(AppException exception) {
    // * This can be replaced with a call to a crash reporting tool of choice
    debugPrint('$exception');
  }

  void logNonErrorState(String controllerName, AsyncValue state,
      {String? statePropertyName}) {
    // * This can be replaced with a call to a crash reporting tool of choice
    if (statePropertyName != null) {
      debugPrint('$controllerName ($statePropertyName): $state');
    } else {
      debugPrint('$controllerName: $state');
    }
  }
}

final loggerProvider = Provider<Logger>((ref) {
  return Logger();
});
