import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:workwith_admin/src/features/add_venue/domain/venue_model.dart';
import 'package:workwith_admin/utils/custom_state.dart';

class EditVenueState extends CustomState {
  final AsyncValue<Position?> currentLocationStatus;
  final AsyncValue<List<Venue>?> venuesStatus;

  @override
  Map<String, AsyncValue> get stateProperties => {
        'currentLocationStatus': currentLocationStatus,
        'venuesStatus': venuesStatus,
      };

  EditVenueState({
    required this.currentLocationStatus,
    required this.venuesStatus,
  });

  EditVenueState.initial()
      : currentLocationStatus = const AsyncValue.data(null),
        venuesStatus = const AsyncValue.data(null);

  EditVenueState copyWith({
    AsyncValue<Position?>? currentLocationStatus,
    AsyncValue<List<Venue>?>? venuesStatus,
    AsyncValue<Set<Marker>?>? markersStatus,
  }) {
    return EditVenueState(
      currentLocationStatus:
          currentLocationStatus ?? this.currentLocationStatus,
      venuesStatus: venuesStatus ?? this.venuesStatus,
    );
  }

  @override
  String toString() =>
      'VenueDisplayPageState(currentLocationStatus: $currentLocationStatus, venuesStatus: $venuesStatus)';

  @override
  bool operator ==(covariant EditVenueState other) {
    if (identical(this, other)) return true;

    return other.currentLocationStatus == currentLocationStatus &&
        other.venuesStatus == venuesStatus;
  }

  @override
  int get hashCode => currentLocationStatus.hashCode ^ venuesStatus.hashCode;
}
