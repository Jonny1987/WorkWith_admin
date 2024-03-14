import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/features/add_venue/domain/venue_photo_model.dart';

import 'package:workwith_admin/src/features/add_venue/domain/venue_model.dart';
import 'package:workwith_admin/src/features/edit_venue/data/edit_venue_repository.dart';
import 'package:workwith_admin/src/features/edit_venue/domain/google_photo_model.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/edit_venue_popup/edit_venue_popup_controller_state.dart';
import 'package:workwith_admin/src/features/edit_venue/utils/venuePhotos.dart';
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

  Future<void> updateVenue(
    Map<String, dynamic> fields,
    String notes,
    List<VenuePhoto>? venuePhotos,
  ) async {
    state = state.copyWith(updateVenueStatus: const AsyncValue.loading());

    try {
      final futures = [];
      futures.add(editVenueRepository.updateVenue(fields));
      var venueId = fields['id'];
      if (notes.isNotEmpty) {
        futures.add(editVenueRepository.updateNotes(venueId, notes));
      }
      if (venuePhotos != null) {
        futures.add(editVenueRepository.updateVenuePhotosConcurrently(
            venueId, venuePhotos));

        var newVenuePhotos = markPhotosUpdated(venuePhotos);
        state = state.copyWith(
            editedVenuePhotosStatus: AsyncValue.data(newVenuePhotos));
      }
      state = state.copyWith(updateVenueStatus: const AsyncValue.data(true));
    } catch (error, stackTrace) {
      state = state.copyWith(
          updateVenueStatus: AsyncValue.error(error, stackTrace));
    }
  }

  Future<void> createEditedVenuePhoto(List<VenuePhoto> venuePhotos) async {
    state = state.copyWith(editedVenuePhotosStatus: const AsyncValue.loading());
    try {
      var editedVenuePhotos = copyVenuePhotos(venuePhotos);
      state = state.copyWith(
          editedVenuePhotosStatus: AsyncValue.data(editedVenuePhotos));
    } catch (e, st) {
      state = state.copyWith(editedVenuePhotosStatus: AsyncValue.error(e, st));
    }
  }

  Future<void> getVenueImageProviders(BuildContext context) async {
    state =
        state.copyWith(venueImageProvidersStatus: const AsyncValue.loading());

    try {
      var editedVenuePhotos = state.editedVenuePhotosStatus.value;

      if (editedVenuePhotos!.isEmpty) {
        state = state.copyWith(
            venueImageProvidersStatus: const AsyncValue.data([]));
        return;
      }
      var networkImages = await editVenueRepository
          .fetchVenuePhotosConcurrently(editedVenuePhotos);
      if (context.mounted) {
        await imagePreloader.precacheImageList(networkImages, context);
        state = state.copyWith(
            venueImageProvidersStatus: AsyncValue.data(networkImages));
      }
    } catch (e, st) {
      state =
          state.copyWith(venueImageProvidersStatus: AsyncValue.error(e, st));
    }
  }

  Future<void> replaceVenuePhoto(int index, GooglePhoto googlePhoto) async {
    print('replacing photo');
    var editedVenuePhotos = state.editedVenuePhotosStatus.value;

    state = state.copyWith(editedVenuePhotosStatus: const AsyncValue.loading());
    try {
      editedVenuePhotos![index] = editedVenuePhotos[index].copyWith(
        newGoogleImageUrl: googlePhoto.thumbnailUrl,
        isVisitorImage: googlePhoto.isVisitorImage,
        wasUpdated: false,
      );
      state = state.copyWith(
          editedVenuePhotosStatus: AsyncValue.data(editedVenuePhotos));
    } catch (e, st) {
      state = state.copyWith(editedVenuePhotosStatus: AsyncValue.error(e, st));
    }
  }

  Future<void> insertVenuePhoto(int index, GooglePhoto googlePhoto) async {
    print('inserting photo');
    var editedVenuePhotos = state.editedVenuePhotosStatus.value;

    state = state.copyWith(editedVenuePhotosStatus: const AsyncValue.loading());
    try {
      var newVenuePhoto = VenuePhoto(
        id: null,
        imagePath: null,
        // because position is 1-indexed but index is 0-indexed
        position: index + 1,
        googleImageUrl: null,
        newGoogleImageUrl: googlePhoto.thumbnailUrl,
        wasUpdated: false,
        updatedAt: null,
        wasInserted: true,
        isVisitorImage: googlePhoto.isVisitorImage,
      );
      editedVenuePhotos!.insert(index, newVenuePhoto);
      for (var i = index + 1; i < editedVenuePhotos.length; i++) {
        editedVenuePhotos[i] = editedVenuePhotos[i].copyWith(position: i + 1);
      }
      state = state.copyWith(
          editedVenuePhotosStatus: AsyncValue.data(editedVenuePhotos));
    } catch (e, st) {
      state = state.copyWith(editedVenuePhotosStatus: AsyncValue.error(e, st));
    }
  }

  Future<void> unstageVenuePhoto(int index) async {
    print('unstaging photo');
    var editedVenuePhotos = state.editedVenuePhotosStatus.value;

    state = state.copyWith(editedVenuePhotosStatus: const AsyncValue.loading());
    try {
      if (editedVenuePhotos![index].wasInserted == true) {
        editedVenuePhotos.removeAt(index);
      } else {
        editedVenuePhotos[index] = editedVenuePhotos[index].unstage();
      }
      state = state.copyWith(
          editedVenuePhotosStatus: AsyncValue.data(editedVenuePhotos));
    } catch (e, st) {
      state = state.copyWith(editedVenuePhotosStatus: AsyncValue.error(e, st));
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
