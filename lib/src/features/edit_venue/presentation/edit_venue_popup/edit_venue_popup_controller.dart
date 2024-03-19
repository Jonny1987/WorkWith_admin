import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/features/add_venue/domain/venue_photo_change_model.dart';
import 'package:workwith_admin/src/features/add_venue/domain/venue_photo_model.dart';

import 'package:workwith_admin/src/features/add_venue/domain/venue_model.dart';
import 'package:workwith_admin/src/features/edit_venue/data/edit_venue_repository.dart';
import 'package:workwith_admin/src/features/edit_venue/domain/google_photo_model.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/edit_venue_popup/edit_venue_popup_controller_state.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/edit_venue_tab/edit_venue_controller.dart';
import 'package:workwith_admin/utils/precache.dart';

class EditVenuePopupController
    extends StateNotifier<EditVenuePopupControllerState> {
  final Venue venue;
  final EditVenueRepository editVenueRepository;
  final EditVenueController editVenueController;
  final ImagePreloader imagePreloader;
  EditVenuePopupController({
    required this.venue,
    required this.editVenueRepository,
    required this.editVenueController,
    required this.imagePreloader,
  }) : super(EditVenuePopupControllerState.initial());

  Future<void> updateVenue(
    Map<String, dynamic> fields,
    String notes,
    List<VenuePhotoChange?> venuePhotoChanges,
  ) async {
    print('updating venue');
    state = state.copyWith(updateVenueStatus: const AsyncValue.loading());
    print('venuePhotoChanges: $venuePhotoChanges');
    try {
      List<Future> futures = [];
      List<VenuePhoto> newVenuePhotos = [];

      futures.add(editVenueRepository.updateVenue(fields));
      var venueId = fields['id'];

      if (notes.isNotEmpty) {
        futures.add(editVenueRepository.upsertNotes(venueId, notes));
      }

      if (!venuePhotoChanges.every((element) => element == null)) {
        futures.add(editVenueRepository
            .updateVenuePhotosConcurrently(venueId, venuePhotoChanges)
            .then((venuePhotos) {
          newVenuePhotos = venuePhotos;
        }));
      }
      await Future.wait(futures);

      if (!venuePhotoChanges.every((element) => element == null)) {
        editVenueController.refreshVenuePhotosList(venueId, newVenuePhotos);

        state = state.copyWith(
            venuePhotoChangesStatus:
                AsyncValue.data(List.filled(venuePhotoChanges.length, null)));
      }

      state = state.copyWith(updateVenueStatus: const AsyncValue.data(true));
    } catch (error, stackTrace) {
      state = state.copyWith(
          updateVenueStatus: AsyncValue.error(error, stackTrace));
    }
  }

  Future<void> createVenuePhotoChanges(List<VenuePhoto> venuePhotos) async {
    state = state.copyWith(venuePhotoChangesStatus: const AsyncValue.loading());
    try {
      var editedVenuePhotos = List<VenuePhotoChange?>.filled(
        venuePhotos.length,
        null,
        growable: true,
      );
      state = state.copyWith(
          venuePhotoChangesStatus: AsyncValue.data(editedVenuePhotos));
    } catch (e, st) {
      state = state.copyWith(venuePhotoChangesStatus: AsyncValue.error(e, st));
    }
  }

  Future<void> getVenueImageProviders(BuildContext context) async {
    state =
        state.copyWith(venueImageProvidersStatus: const AsyncValue.loading());

    try {
      if (venue.venuePhotos?.isEmpty ?? true) {
        state = state.copyWith(
            venueImageProvidersStatus: const AsyncValue.data([]));
        return;
      }
      var networkImages = await editVenueRepository
          .fetchVenuePhotosConcurrently(venue.venuePhotos!);
      if (context.mounted) {
        await imagePreloader.precacheImageList(
          networkImages
              .where((element) => element != null)
              .cast<NetworkImage>()
              .toList(),
          context,
        );
        state = state.copyWith(
            venueImageProvidersStatus: AsyncValue.data(networkImages));
      }
    } catch (e, st) {
      state =
          state.copyWith(venueImageProvidersStatus: AsyncValue.error(e, st));
    }
  }

  Future<void> replaceVenuePhoto(
    int index,
    int? venuePhotoId,
    GooglePhoto googlePhoto,
  ) async {
    print('replacing photo');
    var venuePhotoChanges = state.venuePhotoChangesStatus.value;

    state = state.copyWith(venuePhotoChangesStatus: const AsyncValue.loading());
    try {
      venuePhotoChanges![index] = VenuePhotoChange(
        id: venuePhotoId!,
        googleImageUrl: googlePhoto.thumbnailUrl,
        isVisitorImage: googlePhoto.isVisitorImage,
      );
      state = state.copyWith(
          venuePhotoChangesStatus: AsyncValue.data(venuePhotoChanges));
    } catch (e, st) {
      state = state.copyWith(venuePhotoChangesStatus: AsyncValue.error(e, st));
    }
  }

  Future<void> insertVenuePhoto(
    int index,
    int? venuePhotoId,
    GooglePhoto googlePhoto,
  ) async {
    print('inserting photo');
    var venuePhotoChanges = state.venuePhotoChangesStatus.value;
    var venueImageProviders = state.venueImageProvidersStatus.value;
    print('venuePhotoChanges: $venuePhotoChanges');

    state = state.copyWith(
      venuePhotoChangesStatus: const AsyncValue.loading(),
      venueImageProvidersStatus: const AsyncValue.loading(),
    );
    try {
      var newChange = VenuePhotoChange(
        // because position is 1-indexed but index is 0-indexed
        position: index + 1,
        googleImageUrl: googlePhoto.thumbnailUrl,
        isVisitorImage: googlePhoto.isVisitorImage,
      );
      for (var i = index; i < venuePhotoChanges!.length; i++) {
        final VenuePhoto venuePhoto = venue.venuePhotos![i];
        VenuePhotoChange currentChange = venuePhotoChanges[i] ??
            VenuePhotoChange(
              id: venuePhoto.id,
              position: venuePhoto.position,
            );
        venuePhotoChanges[i] =
            currentChange.copyWith(position: venuePhoto.position + 1);
      }
      venuePhotoChanges.insert(index, newChange);
      venueImageProviders!.insert(index, null);
      state = state.copyWith(
        venuePhotoChangesStatus: AsyncValue.data(venuePhotoChanges),
        venueImageProvidersStatus: AsyncValue.data(venueImageProviders),
      );
    } catch (e, st) {
      state = state.copyWith(venuePhotoChangesStatus: AsyncValue.error(e, st));
    }
  }

  Future<void> unstageVenuePhoto(int index) async {
    print('unstaging photo');
    var venuePhotoChanges = state.venuePhotoChangesStatus.value;
    var venueImageProviders = state.venueImageProvidersStatus.value;

    state = state.copyWith(
      venuePhotoChangesStatus: const AsyncValue.loading(),
    );
    try {
      if (venuePhotoChanges![index]!.id == null) {
        state = state.copyWith(
          venueImageProvidersStatus: const AsyncValue.loading(),
        );
        venuePhotoChanges.removeAt(index);
        venueImageProviders!.removeAt(index);
        state = state.copyWith(
            venueImageProvidersStatus: AsyncValue.data(venueImageProviders));
      } else {
        venuePhotoChanges[index] = null;
      }
      state = state.copyWith(
          venuePhotoChangesStatus: AsyncValue.data(venuePhotoChanges));
    } catch (e, st) {
      state = state.copyWith(venuePhotoChangesStatus: AsyncValue.error(e, st));
    }
  }
}

final editVenuePopupControllerProvider = StateNotifierProvider.autoDispose
    .family<EditVenuePopupController, EditVenuePopupControllerState, Venue>(
        (ref, venue) {
  return EditVenuePopupController(
      venue: venue,
      editVenueRepository: ref.watch(editVenueRepositoryProvider),
      editVenueController: ref.watch(editVenueControllerProvider.notifier),
      imagePreloader: ref.watch(imagePreloaderProvider));
});
