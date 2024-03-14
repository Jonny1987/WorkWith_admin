import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/utils/custom_state.dart';

class EditVenuePopupControllerState extends CustomState {
  final AsyncValue<int?> updateVenueStatus;
  final AsyncValue<List<ImageProvider>?> venueImagesStatus;

  @override
  Map<String, AsyncValue> get stateProperties => {
        'updateVenueState': updateVenueStatus,
        'venueImagesState': venueImagesStatus,
      };

  EditVenuePopupControllerState({
    required this.updateVenueStatus,
    required this.venueImagesStatus,
  });

  factory EditVenuePopupControllerState.initial() {
    return EditVenuePopupControllerState(
      updateVenueStatus: const AsyncValue.data(null),
      venueImagesStatus: const AsyncValue.data(null),
    );
  }

  EditVenuePopupControllerState copyWith({
    AsyncValue<int?>? updateVenueStatus,
    AsyncValue<List<ImageProvider>?>? venueImagesStatus,
  }) {
    return EditVenuePopupControllerState(
      updateVenueStatus: updateVenueStatus ?? this.updateVenueStatus,
      venueImagesStatus: venueImagesStatus ?? this.venueImagesStatus,
    );
  }

  @override
  String toString() =>
      'ExitVenuePopupState(updateVenueState: $updateVenueStatus, venueImagesState: $venueImagesStatus)';

  @override
  bool operator ==(covariant EditVenuePopupControllerState other) {
    if (identical(this, other)) return true;

    return other.updateVenueStatus == updateVenueStatus &&
        other.venueImagesStatus == venueImagesStatus;
  }

  @override
  int get hashCode => updateVenueStatus.hashCode ^ venueImagesStatus.hashCode;
}
