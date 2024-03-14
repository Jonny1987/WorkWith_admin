import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/features/edit_venue/data/google_image_selector_repository.dart';
import 'package:workwith_admin/src/features/edit_venue/domain/google_photos_page_model.dart';

class GooglePhotoSelectorController
    extends StateNotifier<AsyncValue<GooglePhotosResults?>> {
  final String placeDataId;
  final GoogleImageSelectorRepository repository;

  GooglePhotoSelectorController({
    required this.placeDataId,
    required this.repository,
  }) : super(const AsyncValue.data(null));

  Future<void> getVenueGooglePhotos({
    required String categoryId,
    required String? nextPageToken,
  }) async {
    var currentPhotos = state.value?.googlePhotos ?? [];
    try {
      GooglePhotosResults? photos;
      if (nextPageToken == null) {
        photos = await repository.getVenuePhotos(
          dataId: placeDataId,
          categoryId: categoryId,
        );
      } else {
        photos = await repository.getVenuePhotos(
          dataId: placeDataId,
          categoryId: categoryId,
          nextPageToken: nextPageToken,
        );
      }
      var newPage = GooglePhotosResults(
        nextPageToken: photos.nextPageToken,
        googlePhotos: [...currentPhotos, ...photos.googlePhotos],
      );
      state = AsyncValue.data(newPage);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final googlePhotoSelectorControllerProvider = StateNotifierProvider.autoDispose
    .family<GooglePhotoSelectorController, AsyncValue<GooglePhotosResults?>,
        String>(
  (ref, placeDataId) {
    final repository = ref.watch(googleImageSelectorRepositoryProvider);
    return GooglePhotoSelectorController(
      placeDataId: placeDataId,
      repository: repository,
    );
  },
);
