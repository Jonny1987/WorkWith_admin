// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class VenuePhotoChange {
  final int? id;
  final int? position;
  final String? googleImageUrl;
  final bool? isVisitorImage;

  VenuePhotoChange({
    this.id,
    this.position,
    this.googleImageUrl,
    this.isVisitorImage,
  });

  VenuePhotoChange copyWith({
    int? id,
    int? position,
    String? googleImageUrl,
    bool? isVisitorImage,
  }) {
    return VenuePhotoChange(
      id: id ?? this.id,
      position: position ?? this.position,
      googleImageUrl: googleImageUrl ?? this.googleImageUrl,
      isVisitorImage: isVisitorImage ?? this.isVisitorImage,
    );
  }

  factory VenuePhotoChange.fromMap(Map<String, dynamic> map) {
    return VenuePhotoChange(
      id: map['id'] != null ? map['id'] as int : null,
      position: map['position'] != null ? map['position'] as int : null,
      googleImageUrl: map['googleImageUrl'] != null
          ? map['googleImageUrl'] as String
          : null,
      isVisitorImage:
          map['isVisitorImage'] != null ? map['isVisitorImage'] as bool : null,
    );
  }

  @override
  String toString() {
    return 'VenuePhotoChange(id: $id, position: $position, googleImageUrl: $googleImageUrl, isVisitorImage: $isVisitorImage)';
  }

  @override
  bool operator ==(covariant VenuePhotoChange other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.position == position &&
        other.googleImageUrl == googleImageUrl &&
        other.isVisitorImage == isVisitorImage;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        position.hashCode ^
        googleImageUrl.hashCode ^
        isVisitorImage.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'position': position,
      'google_image_url': googleImageUrl,
      'is_visitor_image': isVisitorImage,
    };
  }

  String toJson() => json.encode(toMap());

  factory VenuePhotoChange.fromJson(String source) =>
      VenuePhotoChange.fromMap(json.decode(source) as Map<String, dynamic>);
}
