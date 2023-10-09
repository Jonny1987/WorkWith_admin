import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workwith_admin/pages/splash_page.dart';
import 'package:workwith_admin/utils/constants.dart';

Future<void> setGoogleMapsRenderer() async {
  AndroidMapRenderer mapRenderer = AndroidMapRenderer.platformDefault;
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    WidgetsFlutterBinding.ensureInitialized();
    mapRenderer = await mapsImplementation
        .initializeWithRenderer(AndroidMapRenderer.latest);
  }
}

Future<void> main() async {
  await setGoogleMapsRenderer();
  await Supabase.initialize(
    url: 'https://deyrvouslmxlaqisulmo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRleXJ2b3VzbG14bGFxaXN1bG1vIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTU3NjM5NzYsImV4cCI6MjAxMTMzOTk3Nn0._LUDdAHW4cjuu5NlQYdNTZuktuwptT2v_f8W1QnjwSU',
  );
  await dotenv.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WorkWith admin',
      theme: appTheme,
      home: const SplashPage(),
    );
  }
}
