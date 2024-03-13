import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/edit_venue_tab/edit_venue_controller.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/map_widget/map_widget_controller.dart';

class EditVenueMapWidget extends ConsumerStatefulWidget {
  const EditVenueMapWidget({super.key});

  @override
  ConsumerState<EditVenueMapWidget> createState() => _EditVenueMapWidgetState();
}

class _EditVenueMapWidgetState extends ConsumerState<EditVenueMapWidget> {
  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
        editVenueControllerProvider.select((value) => value.venuesStatus),
        (_, state) {
      state.whenData((venues) {
        if (venues != null) {
          ref
              .watch(editVenueMapWidgetControllerProvider.notifier)
              .createMarkers(venues, context);
        }
      });
    });

    var markersState = ref.watch(editVenueMapWidgetControllerProvider);
    var currentLocationState = ref.watch(editVenueControllerProvider
        .select((value) => value.currentLocationStatus));

    return markersState.isLoading || markersState.value == null
        ? const CircularProgressIndicator()
        : GoogleMap(
            buildingsEnabled: false,
            tiltGesturesEnabled: false,
            rotateGesturesEnabled: false,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            myLocationEnabled: true,
            markers: markersState.value!,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(currentLocationState.value!.latitude,
                  currentLocationState.value!.longitude),
              zoom: 15,
            ),
            myLocationButtonEnabled: true,
          );
  }
}
