import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workwith_admin/src/routing/app_router.dart';
import 'package:workwith_admin/utils/constants.dart';

/// Page to redirect users to the appropriate page depending on the initial auth state
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    // await for for the widget to mount
    await Future.delayed(Duration.zero);

    final session = supabase.auth.currentSession;
    print("session: $session");
    if (context.mounted) {
      if (session == null) {
        context.goNamed(AppRoute.login.name);
      } else {
        context.goNamed(AppRoute.home.name);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: preloader);
  }
}
