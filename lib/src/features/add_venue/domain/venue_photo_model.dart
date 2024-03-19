class VenuePhoto {
  final int id;
  final int position;
  final String imagePath;
  final String? googleImageUrl;
  final String? updatedGoogleUrlAt;

  VenuePhoto({
    required this.id,
    required this.position,
    required this.imagePath,
    required this.googleImageUrl,
    required this.updatedGoogleUrlAt,
  });

  VenuePhoto copyWith({
    int? id,
    int? position,
    String? imagePath,
    String? googleImageUrl,
    String? updatedGoogleUrlAt,
  }) {
    return VenuePhoto(
      id: id ?? this.id,
      position: position ?? this.position,
      imagePath: imagePath ?? this.imagePath,
      googleImageUrl: googleImageUrl ?? this.googleImageUrl,
      updatedGoogleUrlAt: updatedGoogleUrlAt ?? this.updatedGoogleUrlAt,
    );
  }

  factory VenuePhoto.fromMap(Map<String, dynamic> map) {
    return VenuePhoto(
      id: map['id'] as int,
      position: map['position'] as int,
      imagePath: map['image_path'] as String,
      googleImageUrl: map['google_image_url'],
      updatedGoogleUrlAt: map['updated_google_url_at'] as String?,
    );
  }

  @override
  String toString() =>
      'VenuePhoto(id: $id, position: $position, googleImageUrl: $googleImageUrl, imagePath: $imagePath, updatedGoogleUrlAt: $updatedGoogleUrlAt)';

  @override
  bool operator ==(covariant VenuePhoto other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.position == position &&
        other.imagePath == imagePath &&
        other.googleImageUrl == googleImageUrl &&
        other.updatedGoogleUrlAt == updatedGoogleUrlAt;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      position.hashCode ^
      imagePath.hashCode ^
      googleImageUrl.hashCode ^
      updatedGoogleUrlAt.hashCode;
}
