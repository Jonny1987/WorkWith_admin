import 'package:flutter/foundation.dart';

class Venue {
  final int id;
  final String name;
  final int? internetSpeed;
  final double? americanoPrice;
  final int? seatsWithSockets;
  final List<String>? imagePaths;
  final double lat;
  final double long;
  final bool enabled;
  final String? notes;

  Venue({
    required this.id,
    required this.name,
    required this.internetSpeed,
    required this.americanoPrice,
    required this.seatsWithSockets,
    required this.imagePaths,
    required this.lat,
    required this.long,
    required this.enabled,
    required this.notes,
  });

  factory Venue.fromMap(Map<String, dynamic> map) {
    return Venue(
      id: map['id'],
      name: map['name'],
      internetSpeed: map['internet_speed'],
      americanoPrice: map['americano_price']?.toDouble(),
      seatsWithSockets: map['seats_with_sockets'],
      imagePaths: map['image_paths'] != null
          ? List<String>.from(map['image_paths'])
          : null,
      lat: map['lat'],
      long: map['long'],
      enabled: map['enabled'],
      notes: map['notes'],
    );
  }

  Venue copyWith({
    int? id,
    String? name,
    int? internetSpeed,
    double? americanoPrice,
    int? seatsWithSockets,
    List<String>? imagePaths,
    double? lat,
    double? long,
    bool? enabled,
    String? notes,
  }) {
    return Venue(
      id: id ?? this.id,
      name: name ?? this.name,
      internetSpeed: internetSpeed ?? this.internetSpeed,
      americanoPrice: americanoPrice ?? this.americanoPrice,
      seatsWithSockets: seatsWithSockets ?? this.seatsWithSockets,
      imagePaths: imagePaths ?? this.imagePaths,
      lat: lat ?? this.lat,
      long: long ?? this.long,
      enabled: enabled ?? this.enabled,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    return 'Venue(id: $id, name: $name, internetSpeed: $internetSpeed, americanoPrice: $americanoPrice, seatsWithSockets: $seatsWithSockets, imagePaths: $imagePaths, lat: $lat, long: $long, enabled: $enabled, notes: $notes)';
  }

  @override
  bool operator ==(covariant Venue other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.internetSpeed == internetSpeed &&
        other.americanoPrice == americanoPrice &&
        other.seatsWithSockets == seatsWithSockets &&
        listEquals(other.imagePaths, imagePaths) &&
        other.lat == lat &&
        other.long == long &&
        other.enabled == enabled &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        internetSpeed.hashCode ^
        americanoPrice.hashCode ^
        seatsWithSockets.hashCode ^
        imagePaths.hashCode ^
        lat.hashCode ^
        long.hashCode ^
        enabled.hashCode ^
        notes.hashCode;
  }
}
