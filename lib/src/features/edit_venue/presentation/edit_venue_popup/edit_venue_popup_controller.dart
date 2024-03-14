import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:workwith_admin/src/features/add_venue/domain/venue_model.dart';
import 'package:workwith_admin/src/features/edit_venue/data/edit_venue_repository.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/edit_venue_popup/edit_venue_popup_controller_state.dart';
import 'package:workwith_admin/utils/precache.dart';

class EditVenuePopupController
    extends StateNotifier<EditVenuePopupControllerState> {
  final Venue venue;
  final EditVenueRepository editVenueRepository;
  final ImagePreloader imagePreloader;
  EditVenuePopupController({
    required this.venue,
    required this.editVenueRepository,
    required this.imagePreloader,
  }) : super(EditVenuePopupControllerState.initial());

  Future<void> updateVenue(Map<String, dynamic> inserts, String notes) async {
    state = state.copyWith(updateVenueStatus: const AsyncValue.loading());
    try {
      final int newVenueId = await editVenueRepository.updateVenue(inserts);
      if (notes.isNotEmpty) {
        await editVenueRepository.updateNotes(newVenueId, notes);
      }
      state = state.copyWith(updateVenueStatus: AsyncValue.data(newVenueId));
    } catch (error, stackTrace) {
      state = state.copyWith(
          updateVenueStatus: AsyncValue.error(error, stackTrace));
    }
  }

  Future<void> getVenueImages(BuildContext context) async {
    state = state.copyWith(venueImagesStatus: const AsyncValue.loading());

    try {
      var venueImages =
          await editVenueRepository.fetchVenueImagesConcurrently(venue);
      if (context.mounted) {
        await imagePreloader.precacheImageList(venueImages, context);
        state = state.copyWith(venueImagesStatus: AsyncValue.data(venueImages));
      }
    } catch (e, st) {
      state = state.copyWith(venueImagesStatus: AsyncValue.error(e, st));
    }
  }
}

final editVenuePopupControllerProvider = StateNotifierProvider.autoDispose
    .family<EditVenuePopupController, EditVenuePopupControllerState, Venue>(
        (ref, venue) {
  return EditVenuePopupController(
      venue: venue,
      editVenueRepository: ref.watch(editVenueRepositoryProvider),
      imagePreloader: ref.watch(imagePreloaderProvider));
});
