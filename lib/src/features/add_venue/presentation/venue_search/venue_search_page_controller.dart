import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workwith_admin/src/features/add_venue/data/add_venue_repository.dart';

class VenueSearchPageController extends StateNotifier<AsyncValue<Position?>> {
  final AddVenueRepository venuesRepository;
  VenueSearchPageController({required this.venuesRepository})
      : super(const AsyncValue.data(null));

  Future<void> getCurrentLocation() async {
    state = const AsyncValue.loading();
    try {
      var currentLocationstatus = await venuesRepository.getCurrentLocation(
          accuracy: LocationAccuracy.high);
      state = AsyncValue.data(currentLocationstatus);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final venueSearchPageControllerProvider = StateNotifierProvider.autoDispose<
    VenueSearchPageController, AsyncValue<Position?>>(
  (ref) {
    return VenueSearchPageController(
        venuesRepository: ref.watch(addVenueRepositoryProvider));
  },
);
