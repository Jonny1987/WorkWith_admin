class VenuePhoto {
  final int? id;
  final String? imagePath;
  final int position;
  final String? googleImageUrl;
  final String? newGoogleImageUrl;
  final bool? wasUpdated;
  final bool? isVisitorImage;
  final String? updatedAt;
  final bool? wasInserted;

  VenuePhoto({
    required this.id,
    required this.imagePath,
    required this.position,
    required this.googleImageUrl,
    this.newGoogleImageUrl,
    this.wasUpdated,
    this.isVisitorImage,
    required this.updatedAt,
    required this.wasInserted,
  });

  VenuePhoto copyWith({
    int? id,
    String? imagePath,
    int? position,
    String? googleImageUrl,
    String? newGoogleImageUrl,
    bool? wasUpdated,
    bool? isVisitorImage,
    String? updatedAt,
    bool? wasInserted,
  }) {
    return VenuePhoto(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      position: position ?? this.position,
      googleImageUrl: googleImageUrl ?? this.googleImageUrl,
      newGoogleImageUrl: newGoogleImageUrl ?? this.newGoogleImageUrl,
      wasUpdated: wasUpdated ?? this.wasUpdated,
      isVisitorImage: isVisitorImage ?? this.isVisitorImage,
      updatedAt: updatedAt ?? this.updatedAt,
      wasInserted: wasInserted ?? this.wasInserted,
    );
  }

  VenuePhoto unstage() {
    return VenuePhoto(
      id: id,
      imagePath: imagePath,
      position: position,
      googleImageUrl: googleImageUrl,
      newGoogleImageUrl: null,
      wasUpdated: null,
      isVisitorImage: null,
      updatedAt: updatedAt,
      wasInserted: null,
    );
  }

  factory VenuePhoto.fromMap(Map<String, dynamic> map) {
    return VenuePhoto(
      id: map['id'] as int,
      imagePath: map['image_path'] as String,
      position: map['position'] as int,
      googleImageUrl: map['google_image_url'],
      newGoogleImageUrl: null,
      wasUpdated: null,
      isVisitorImage: null,
      updatedAt: map['updated_at'] as String,
      wasInserted: null,
    );
  }

  @override
  String toString() =>
      'VenuePhoto(id: $id, imagePath: $imagePath, position: $position, googleImageUrl: $googleImageUrl, newGoogleImageUrl: $newGoogleImageUrl, wasUpdated: $wasUpdated, isVisitorImage: $isVisitorImage, updatedAt: $updatedAt, wasInserted: $wasInserted)';

  @override
  bool operator ==(covariant VenuePhoto other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.imagePath == imagePath &&
        other.position == position &&
        other.googleImageUrl == googleImageUrl &&
        other.newGoogleImageUrl == newGoogleImageUrl &&
        other.wasUpdated == wasUpdated &&
        other.isVisitorImage == isVisitorImage &&
        other.updatedAt == updatedAt &&
        other.wasInserted == wasInserted;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      imagePath.hashCode ^
      position.hashCode ^
      googleImageUrl.hashCode ^
      newGoogleImageUrl.hashCode ^
      wasUpdated.hashCode ^
      isVisitorImage.hashCode ^
      updatedAt.hashCode ^
      wasInserted.hashCode;
}
