import 'package:go_router/go_router.dart';
import 'package:workwith_admin/src/features/add_venue/domain/venue_model.dart';
import 'package:workwith_admin/src/features/add_venue/presentation/add_venue_popup/add_venue_popup.dart';
import 'package:workwith_admin/src/features/auth/presentation/email_password_reset_page/email_password_reset_page.dart';
import 'package:workwith_admin/src/features/auth/presentation/login/login_page.dart';
import 'package:workwith_admin/src/features/auth/presentation/password_reset_page/password_reset_page.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/edit_venue_popup/edit_venue_popup.dart';
import 'package:workwith_admin/src/features/home/home_page.dart';
import 'package:workwith_admin/src/features/home/tab_enum.dart';
import 'package:workwith_admin/src/features/splash/splash_page.dart';

enum AppRoute {
  splash,
  home,
  login,
  addVenue,
  editVenue,
  emailPasswordReset,
  passwordReset,
}

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/splash',
        name: AppRoute.splash.name,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoute.login.name,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/home',
        name: AppRoute.home.name,
        builder: (context, state) {
          final tabName = state.uri.queryParameters['tab'];
          final tab =
              tabName == null ? TabsEnum.editVenue : getTabFromString(tabName);
          return HomePage(
            tab: tab,
          );
        },
      ),
      GoRoute(
        path: '/edit-venue',
        name: AppRoute.editVenue.name,
        builder: (context, state) {
          var venue = state.extra as Venue;
          return EditVenuePopup(venue: venue);
        },
      ),
      GoRoute(
        path: '/add-venue',
        name: AppRoute.addVenue.name,
        builder: (context, state) {
          var placeDetails = state.extra;
          return AddVenuePopup(placeDetails: placeDetails);
        },
      ),
      GoRoute(
        path: '/email-password-reset',
        name: AppRoute.emailPasswordReset.name,
        builder: (context, state) {
          return const EmailPasswordResetPage();
        },
      ),
      GoRoute(
        path: '/password-reset',
        name: AppRoute.passwordReset.name,
        builder: (context, state) {
          return const PasswordResetPage();
        },
      ),
    ],
  );
}
