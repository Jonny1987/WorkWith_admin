import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workwith_admin/src/exceptions/app_exceptions.dart';
import 'package:workwith_admin/src/features/add_venue/data/add_venue_repository.dart';

class LocationPermissionsController extends StateNotifier<AsyncValue<bool?>> {
  final AddVenueRepository venuesRepository;
  LocationPermissionsController({required this.venuesRepository})
      : super(const AsyncValue.data(null));

  Future<void> getLocationPermission() async {
    state = const AsyncValue.loading();

    try {
      if (!await _checkServiceEnabled()) {
        throw LocationServiceDisabledCustomException();
      }

      var permission = await venuesRepository.checkLocationPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('****** existing location permission: $permission');
        permission = await venuesRepository.requestLocationPermission();
        debugPrint(
            '*********** location permission request result: $permission');
      }

      switch (permission) {
        case LocationPermission.denied:
          throw LocationPermissionDeniedCustomException();

        case LocationPermission.deniedForever:
          throw LocationPermissionDeniedForeverCustomException();

        case LocationPermission.always:
        case LocationPermission.whileInUse:
          state = const AsyncValue.data(true);
        default:
          throw Exception('Unhandled location permission: $permission');
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> _checkServiceEnabled() async {
    final serviceEnabled = await venuesRepository.isLocationServiceEnabled();
    debugPrint('****** serviceEnabled: $serviceEnabled');
    return serviceEnabled;
  }
}

final locationPermissionsControllerProvider = StateNotifierProvider.autoDispose<
    LocationPermissionsController, AsyncValue<bool?>>(
  (ref) {
    var venuesRepository = ref.watch(addVenueRepositoryProvider);
    return LocationPermissionsController(venuesRepository: venuesRepository);
  },
);
