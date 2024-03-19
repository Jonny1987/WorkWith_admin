import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/exceptions/app_exceptions.dart';
import 'package:workwith_admin/src/exceptions/logger.dart';
import 'package:workwith_admin/utils/custom_state.dart';

/// Error logger class to keep track of all AsyncError states that are set
/// by the controllers in the app
class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    final logger = container.read(loggerProvider);
    if (newValue is CustomState) {
      var changedProperty =
          newValue.changedProperty(previousValue as CustomState);
      if (changedProperty != null) {
        sendToLogger(
          provider: provider,
          state: changedProperty.value,
          logger: logger,
          statePropertyName: changedProperty.name,
        );
      }
    } else if (newValue is AsyncValue) {
      sendToLogger(provider: provider, state: newValue, logger: logger);
    } else {
      throw Exception('newValue is not a CustomState or AsyncValue');
    }
  }
}

String getControllerName(ProviderBase provider) {
  var providerName = provider.runtimeType.toString();
  return providerName.split('<')[1].split(',')[0];
}

void sendToLogger(
    {required ProviderBase provider,
    required AsyncValue state,
    required Logger logger,
    String? statePropertyName}) {
  if (state is AsyncError) {
    if (state.error is AppException) {
      // only prints the AppException data
      logger.logAppException(state.error as AppException);
    } else {
      // prints everything including the stack trace
      logger.logError(state.error, state.stackTrace);
    }
    // If it has an argument then it's a family provider and there will
    //be a lot of them (eg. Venues) so we only want to print the errors
    // } else if (provider.argument == null) {
  } else {
    var controllerName = getControllerName(provider);
    logger.logNonErrorState(controllerName, state,
        statePropertyName: statePropertyName);
  }
}
