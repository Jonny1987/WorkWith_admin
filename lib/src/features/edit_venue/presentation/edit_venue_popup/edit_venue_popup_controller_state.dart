import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/features/add_venue/domain/venue_photo_model.dart';
import 'package:workwith_admin/utils/custom_state.dart';

class EditVenuePopupControllerState extends CustomState {
  final AsyncValue<bool?> updateVenueStatus;
  final AsyncValue<List<NetworkImage>?> venueImageProvidersStatus;
  final AsyncValue<List<VenuePhoto>?> editedVenuePhotosStatus;

  @override
  Map<String, AsyncValue> get stateProperties => {
        'updateVenueStatus': updateVenueStatus,
        'venueImageProvidersStatus': venueImageProvidersStatus,
        'editedVenuePhotosStatus': editedVenuePhotosStatus,
      };

  EditVenuePopupControllerState({
    required this.updateVenueStatus,
    required this.venueImageProvidersStatus,
    required this.editedVenuePhotosStatus,
  });

  factory EditVenuePopupControllerState.initial() {
    return EditVenuePopupControllerState(
      updateVenueStatus: const AsyncValue.data(null),
      venueImageProvidersStatus: const AsyncValue.data(null),
      editedVenuePhotosStatus: const AsyncValue.data(null),
    );
  }

  EditVenuePopupControllerState copyWith({
    AsyncValue<bool?>? updateVenueStatus,
    AsyncValue<List<NetworkImage>?>? venueImageProvidersStatus,
    AsyncValue<List<VenuePhoto>?>? editedVenuePhotosStatus,
  }) {
    return EditVenuePopupControllerState(
      updateVenueStatus: updateVenueStatus ?? this.updateVenueStatus,
      venueImageProvidersStatus:
          venueImageProvidersStatus ?? this.venueImageProvidersStatus,
      editedVenuePhotosStatus:
          editedVenuePhotosStatus ?? this.editedVenuePhotosStatus,
    );
  }

  @override
  String toString() =>
      'ExitVenuePopupState(updateVenueState: $updateVenueStatus, venuePhotosState: $venueImageProvidersStatus, editedVenuePhotosState: $editedVenuePhotosStatus)';

  @override
  bool operator ==(covariant EditVenuePopupControllerState other) {
    if (identical(this, other)) return true;

    return other.updateVenueStatus == updateVenueStatus &&
        other.venueImageProvidersStatus == venueImageProvidersStatus &&
        other.editedVenuePhotosStatus == editedVenuePhotosStatus;
  }

  @override
  int get hashCode =>
      updateVenueStatus.hashCode ^
      venueImageProvidersStatus.hashCode ^
      editedVenuePhotosStatus.hashCode;
}
