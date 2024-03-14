import 'package:flutter/foundation.dart';
import 'package:workwith_admin/src/features/edit_venue/domain/google_photo_model.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/google_image_selector/category_enum.dart';

class GooglePhotosResults {
  final String? nextPageToken;
  final List<GooglePhoto> googlePhotos;

  GooglePhotosResults({
    required this.nextPageToken,
    required this.googlePhotos,
  });

  GooglePhotosResults copyWith({
    String? nextPageToken,
    List<GooglePhoto>? googlePhotos,
  }) {
    return GooglePhotosResults(
      nextPageToken: nextPageToken ?? this.nextPageToken,
      googlePhotos: googlePhotos ?? this.googlePhotos,
    );
  }

  factory GooglePhotosResults.fromMap(Map<String, dynamic> map) {
    return GooglePhotosResults(
      nextPageToken: map['serpapi_pagination']?['next_page_token'],
      googlePhotos: List<GooglePhoto>.from(
        map['thumbnails']?.map(
          (thumbnail) => GooglePhoto(
            thumbnailUrl: thumbnail,
            isVisitorImage: map['category_id'] ==
                GooglePhotoCategory.fromVisitors.categoryId,
          ),
        ),
      ),
    );
  }

  @override
  String toString() =>
      'GooglePhotosPageModel(nextPageToken: $nextPageToken, googlePhotos: $googlePhotos)';

  @override
  bool operator ==(covariant GooglePhotosResults other) {
    if (identical(this, other)) return true;

    return other.nextPageToken == nextPageToken &&
        listEquals(other.googlePhotos, googlePhotos);
  }

  @override
  int get hashCode => nextPageToken.hashCode ^ googlePhotos.hashCode;
}
