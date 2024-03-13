import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:workwith_admin/src/features/add_venue/data/add_venue_repository.dart';
import 'package:workwith_admin/src/features/add_venue/presentation/venue_search/autocomplete_search.dart';
import 'package:workwith_admin/src/features/add_venue/presentation/venue_search/add_venue_button.dart';
import 'package:workwith_admin/src/features/add_venue/presentation/venue_search/venue_search_page_controller.dart';
import 'package:workwith_admin/src/routing/app_router.dart';

class VenueSearchPage extends ConsumerStatefulWidget {
  const VenueSearchPage({super.key});

  @override
  ConsumerState<VenueSearchPage> createState() => _VenueSearchPageState();
}

class _VenueSearchPageState extends ConsumerState<VenueSearchPage> {
  Set<Marker> _markers = {};
  dynamic _placeDetails;

  late GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .watch(venueSearchPageControllerProvider.notifier)
          .getCurrentLocation();
    });
  }

  void onSelect(String placeId) async {
    _placeDetails =
        await ref.read(addVenueRepositoryProvider).placeDetails(placeId);
    LatLng position = LatLng(
      _placeDetails['location']['lat'],
      _placeDetails['location']['lng'],
    );
    setState(() {
      _markers = {
        Marker(
          markerId: MarkerId(_placeDetails['placeId']),
          position: position,
          icon: BitmapDescriptor.defaultMarker,
        )
      };
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 15,
        ),
      ));
    });
  }

  void _onAdd() {
    context.pushNamed(AppRoute.addVenue.name, extra: _placeDetails);
  }

  @override
  Widget build(BuildContext context) {
    var currentLocation = ref.watch(venueSearchPageControllerProvider).value;

    return currentLocation == null
        ? const CircularProgressIndicator()
        : Stack(children: [
            GoogleMap(
              markers: _markers,
              buildingsEnabled: false,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              myLocationEnabled: true,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target:
                    LatLng(currentLocation.latitude, currentLocation.longitude),
                zoom: 15,
              ),
              myLocationButtonEnabled: true,
            ),
            if (_placeDetails != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: AddVenueButton(onPress: _onAdd),
                ),
              ),
            AutoCompleteSearch(
              currentLocation:
                  LatLng(currentLocation.latitude, currentLocation.longitude),
              onSelect: onSelect,
            ),
          ]);
  }
}
