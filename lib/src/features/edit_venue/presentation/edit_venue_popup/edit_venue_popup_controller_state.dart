import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/features/add_venue/domain/venue_photo_change_model.dart';
import 'package:workwith_admin/utils/custom_state.dart';

class EditVenuePopupControllerState extends CustomState {
  final AsyncValue<bool?> updateVenueStatus;
  final AsyncValue<List<NetworkImage?>?> venueImageProvidersStatus;
  final AsyncValue<List<VenuePhotoChange?>?> venuePhotoChangesStatus;

  @override
  Map<String, AsyncValue> get stateProperties => {
        'updateVenueStatus': updateVenueStatus,
        'venueImageProvidersStatus': venueImageProvidersStatus,
        'venuePhotoChangesStatus': venuePhotoChangesStatus,
      };

  EditVenuePopupControllerState({
    required this.updateVenueStatus,
    required this.venueImageProvidersStatus,
    required this.venuePhotoChangesStatus,
  });

  factory EditVenuePopupControllerState.initial() {
    return EditVenuePopupControllerState(
      updateVenueStatus: const AsyncValue.data(null),
      venueImageProvidersStatus: const AsyncValue.data(null),
      venuePhotoChangesStatus: const AsyncValue.data(null),
    );
  }

  EditVenuePopupControllerState copyWith({
    AsyncValue<bool?>? updateVenueStatus,
    AsyncValue<List<NetworkImage?>?>? venueImageProvidersStatus,
    AsyncValue<List<VenuePhotoChange?>?>? venuePhotoChangesStatus,
  }) {
    return EditVenuePopupControllerState(
      updateVenueStatus: updateVenueStatus ?? this.updateVenueStatus,
      venueImageProvidersStatus:
          venueImageProvidersStatus ?? this.venueImageProvidersStatus,
      venuePhotoChangesStatus:
          venuePhotoChangesStatus ?? this.venuePhotoChangesStatus,
    );
  }

  @override
  String toString() =>
      'ExitVenuePopupState(updateVenueState: $updateVenueStatus, venuePhotosState: $venueImageProvidersStatus, venuePhotoChangesStatus: $venuePhotoChangesStatus)';

  @override
  bool operator ==(covariant EditVenuePopupControllerState other) {
    if (identical(this, other)) return true;

    return other.updateVenueStatus == updateVenueStatus &&
        other.venueImageProvidersStatus == venueImageProvidersStatus &&
        other.venuePhotoChangesStatus == venuePhotoChangesStatus;
  }

  @override
  int get hashCode =>
      updateVenueStatus.hashCode ^
      venueImageProvidersStatus.hashCode ^
      venuePhotoChangesStatus.hashCode;
}
