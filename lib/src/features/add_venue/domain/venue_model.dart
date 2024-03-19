import 'package:flutter/foundation.dart';
import 'package:workwith_admin/src/features/add_venue/domain/venue_photo_model.dart';

class Venue {
  final int id;
  final String name;
  final int? internetSpeed;
  final double? americanoPrice;
  final int? seatsWithSockets;
  final List<VenuePhoto>? venuePhotos;
  final double lat;
  final double long;
  final bool enabled;
  final String? notes;
  final String googleMapsDataId;

  Venue({
    required this.id,
    required this.name,
    required this.internetSpeed,
    required this.americanoPrice,
    required this.seatsWithSockets,
    required this.venuePhotos,
    required this.lat,
    required this.long,
    required this.enabled,
    required this.notes,
    required this.googleMapsDataId,
  });

  factory Venue.fromMap(Map<String, dynamic> map) {
    return Venue(
      id: map['id'],
      name: map['name'],
      internetSpeed: map['internet_speed'],
      americanoPrice: map['americano_price']?.toDouble(),
      seatsWithSockets: map['seats_with_sockets'],
      venuePhotos: map['venue_images'] != null
          ? [
              for (var venuePhotoMap in map['venue_images'])
                VenuePhoto.fromMap(venuePhotoMap)
            ]
          : null,
      lat: map['lat'],
      long: map['long'],
      enabled: map['enabled'],
      notes: map['notes'],
      googleMapsDataId: map['google_maps_data_id'],
    );
  }

  Venue copyWith({
    int? id,
    String? name,
    int? internetSpeed,
    double? americanoPrice,
    int? seatsWithSockets,
    List<VenuePhoto>? venuePhotos,
    double? lat,
    double? long,
    bool? enabled,
    String? notes,
    String? googleMapsDataId,
  }) {
    return Venue(
      id: id ?? this.id,
      name: name ?? this.name,
      internetSpeed: internetSpeed ?? this.internetSpeed,
      americanoPrice: americanoPrice ?? this.americanoPrice,
      seatsWithSockets: seatsWithSockets ?? this.seatsWithSockets,
      venuePhotos: venuePhotos ?? this.venuePhotos,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      enabled: enabled ?? this.enabled,
      notes: notes ?? this.notes,
      googleMapsDataId: googleMapsDataId ?? this.googleMapsDataId,
    );
  }

  @override
  String toString() {
    return 'Venue(id: $id, name: $name, internetSpeed: $internetSpeed, americanoPrice: $americanoPrice, seatsWithSockets: $seatsWithSockets, venuePhotos: $venuePhotos, lat: $lat, long: $long, enabled: $enabled, notes: $notes, googleMapsDataId: $googleMapsDataId)';
  }

  @override
  bool operator ==(covariant Venue other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.internetSpeed == internetSpeed &&
        other.americanoPrice == americanoPrice &&
        other.seatsWithSockets == seatsWithSockets &&
        listEquals(other.venuePhotos, venuePhotos) &&
        other.lat == lat &&
        other.long == long &&
        other.enabled == enabled &&
        other.notes == notes &&
        other.googleMapsDataId == googleMapsDataId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        internetSpeed.hashCode ^
        americanoPrice.hashCode ^
        seatsWithSockets.hashCode ^
        venuePhotos.hashCode ^
        lat.hashCode ^
        long.hashCode ^
        enabled.hashCode ^
        notes.hashCode ^
        googleMapsDataId.hashCode;
  }
}
