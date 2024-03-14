import 'package:workwith_admin/src/features/add_venue/domain/venue_photo_model.dart';

List<VenuePhoto> copyVenuePhotos(List<VenuePhoto> venuePhotos) {
  return venuePhotos.map((venuePhoto) => venuePhoto.copyWith()).toList();
}

List<VenuePhoto> markPhotosUpdated(List<VenuePhoto> venuePhotos) {
  var newVenuePhotos = venuePhotos.map((photo) {
    if (photo.wasUpdated == false) {
      return photo.copyWith(
        wasUpdated: true,
      );
    } else {
      return photo;
    }
  }).toList();
  return newVenuePhotos;
}
