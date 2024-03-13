import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workwith_admin/app.dart';
import 'package:workwith_admin/src/exceptions/logger.dart';
import 'package:workwith_admin/src/exceptions/provider_logger.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

// Future<void> setGoogleMapsRenderer() async {
//   AndroidMapRenderer mapRenderer = AndroidMapRenderer.platformDefault;
//   final GoogleMapsFlutterPlatform mapsImplementation =
//       GoogleMapsFlutterPlatform.instance;
//   if (mapsImplementation is GoogleMapsFlutterAndroid) {
//     WidgetsFlutterBinding.ensureInitialized();
//     mapRenderer = await mapsImplementation
//         .initializeWithRenderer(AndroidMapRenderer.latest);
//   }
// }

Future<void> main() async {
  // await setGoogleMapsRenderer();
  WidgetsFlutterBinding.ensureInitialized();

  // Turn off the # in the URLs on the web
  usePathUrlStrategy();

  await dotenv.load();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANONKEY']!,
  );

  // Ensure URL reflects the GoRouter state
  GoRouter.optionURLReflectsImperativeAPIs = true;

  final container = ProviderContainer(
    observers: [ProviderLogger()],
  );
  final logger = container.read(loggerProvider);
  // * Register error handlers. For more info, see:
  // * https://docs.flutter.dev/testing/errors
  registerErrorHandlers(logger);

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(UncontrolledProviderScope(
    container: container,
    child: const MyApp(),
  ));
}

void registerErrorHandlers(Logger errorLogger) {
  // * Show some error UI if any uncaught exception happens
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    errorLogger.logError(details.exception, details.stack);
  };
  // * Handle errors from the underlying platform/OS
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    errorLogger.logError(error, stack);
    return true;
  };
  // * Show some error UI when any widget in the app fails to build
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('An error occurred'),
      ),
      body: Center(child: Text(details.toString())),
    );
  };
}
