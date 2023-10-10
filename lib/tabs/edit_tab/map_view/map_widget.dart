import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:workwith_admin/tabs/edit_tab/edit_venue_popup.dart';
import 'package:workwith_admin/utils/map.dart';

class VenuesMapWidget extends StatefulWidget {
  final LatLng currentLocation;
  const VenuesMapWidget({super.key, required this.currentLocation});

  @override
  State<VenuesMapWidget> createState() => _VenuesMapWidgetState();
}

class _VenuesMapWidgetState extends State<VenuesMapWidget> {
  late GoogleMapController mapController;

  List<dynamic> venues = [];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Set<Marker> _markers = {};

  void _createMarkers(currentLocation) async {
    final venues = await getVenues(currentLocation);
    print('venues: $venues');
    final markers = venues.map((venue) {
      return Marker(
        markerId: MarkerId(venue['id'].toString()),
        position: LatLng(venue['lat'], venue['long']),
        infoWindow: InfoWindow(
          title: venue['name'],
          onTap: () =>
              Navigator.of(context).push(EditVenuePopup.route(venue['id'])),
        ),
        icon: BitmapDescriptor.defaultMarker,
      );
    }).toSet();
    print('markers: $markers');
    setState(() {
      _markers = markers;
    });
  }

  @override
  initState() {
    super.initState();
    _createMarkers(widget.currentLocation);
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      buildingsEnabled: false,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      myLocationEnabled: true,
      markers: _markers,
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: widget.currentLocation,
        zoom: 15,
      ),
      myLocationButtonEnabled: true,
    );
  }
}
