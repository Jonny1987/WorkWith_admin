import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workwith_admin/src/features/edit_venue/data/edit_venue_repository.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/edit_venue_tab/edit_venue_state.dart';

class EditVenueController extends StateNotifier<EditVenueState> {
  final EditVenueRepository editVenueRepository;
  EditVenueController({required this.editVenueRepository})
      : super(EditVenueState.initial());

  Future<void> getCurrentLocation() async {
    state = state.copyWith(currentLocationStatus: const AsyncValue.loading());
    try {
      var currentLocationstatus = await editVenueRepository.getCurrentLocation(
          accuracy: LocationAccuracy.high);
      state = state.copyWith(
          currentLocationStatus: AsyncValue.data(currentLocationstatus));
    } catch (e, st) {
      state = state.copyWith(currentLocationStatus: AsyncValue.error(e, st));
    }
  }

  Future<void> getVenues(Position currentLocation) async {
    state = state.copyWith(venuesStatus: const AsyncValue.loading());

    try {
      var venues = await editVenueRepository.getRecentVenues(100);
      print(venues);
      state = state.copyWith(
        venuesStatus: AsyncValue.data(venues),
      );
    } catch (e, st) {
      state = state.copyWith(venuesStatus: AsyncValue.error(e, st));
    }
  }
}

final editVenueControllerProvider =
    StateNotifierProvider.autoDispose<EditVenueController, EditVenueState>(
  (ref) {
    return EditVenueController(
        editVenueRepository: ref.watch(editVenueRepositoryProvider));
  },
);
