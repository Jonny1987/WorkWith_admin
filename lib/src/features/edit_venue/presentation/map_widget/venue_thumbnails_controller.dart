import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/exceptions/app_exceptions.dart';
import 'package:workwith_admin/src/features/add_venue/domain/venue_model.dart';
import 'package:workwith_admin/src/features/edit_venue/data/edit_venue_repository.dart';
import 'package:workwith_admin/utils/precache.dart';

class VenueThumbnailsController
    extends StateNotifier<AsyncValue<ImageProvider?>> {
  final Venue venue;
  final EditVenueRepository editVenueRepository;
  final ImagePreloader imagePreloader;
  VenueThumbnailsController({
    required this.venue,
    required this.editVenueRepository,
    required this.imagePreloader,
  }) : super(const AsyncValue.data(null));

  Future<void> getVenueThumbnail(
    BuildContext context,
  ) async {
    state = const AsyncValue.loading();

    try {
      if (venue.imagePaths == null || venue.imagePaths!.isEmpty) {
        throw NoImagePathsException(venue: venue);
      }
      var venueThumbnail = await editVenueRepository
          .getVenueThumbnailFromPath(venue.imagePaths![0]);
      if (context.mounted) {
        await imagePreloader.precacheImageUtil(venueThumbnail, context);
        state = AsyncValue.data(venueThumbnail);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final venueThumbnailsControllerProvider = StateNotifierProvider.family<
    VenueThumbnailsController, AsyncValue<ImageProvider?>, Venue>(
  (ref, venue) {
    return VenueThumbnailsController(
      venue: venue,
      editVenueRepository: ref.watch(editVenueRepositoryProvider),
      imagePreloader: ref.watch(imagePreloaderProvider),
    );
  },
);
