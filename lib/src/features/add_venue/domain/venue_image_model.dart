class VenueImage {
  final int id;
  final String imagePath;
  final int position;
  final String? googleImageUrl;

  VenueImage({
    required this.id,
    required this.imagePath,
    required this.position,
    required this.googleImageUrl,
  });

  VenueImage copyWith({
    int? id,
    String? imagePath,
    int? position,
    String? googleImageUrl,
  }) {
    return VenueImage(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      position: position ?? this.position,
      googleImageUrl: googleImageUrl ?? this.googleImageUrl,
    );
  }

  factory VenueImage.fromMap(Map<String, dynamic> map) {
    try {
      return VenueImage(
        id: map['id'] as int,
        imagePath: map['image_path'] as String,
        position: map['position'] as int,
        googleImageUrl: map['google_image_url'],
      );
    } catch (e, st) {
      print('error: $e, $st');
      print('map: $map');
      return VenueImage(
        id: 0,
        imagePath: '',
        position: 0,
        googleImageUrl: '',
      );
    }
  }

  @override
  String toString() =>
      'VenueImage(id: $id, imagePath: $imagePath, position: $position, googleImageUrl: $googleImageUrl)';

  @override
  bool operator ==(covariant VenueImage other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.imagePath == imagePath &&
        other.position == position &&
        other.googleImageUrl == googleImageUrl;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      imagePath.hashCode ^
      position.hashCode ^
      googleImageUrl.hashCode;
}
