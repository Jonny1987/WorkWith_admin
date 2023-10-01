import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:workwith_admin/utils/map.dart';

class MapWidget extends StatefulWidget {
  final LatLng currentLocation;
  const MapWidget({required this.currentLocation});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late GoogleMapController mapController;

  List<dynamic> venues = [];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  List<Marker> _markers = [];

  void _createMarkers(currentLocation) async {
    final venues = await getVenues(currentLocation);
    final markers = venues.map((venue) {
      return Marker(
        markerId: MarkerId(venue['id'].toString()),
        position: LatLng(venue['lat'], venue['long']),
        infoWindow: InfoWindow(
          title: venue['name'],
          snippet: venue['address'],
        ),
        icon: BitmapDescriptor.defaultMarker,
      );
    }).toList();
    setState(() {
      _markers = markers;
    });
  }

  initState() {
    super.initState();
    _createMarkers(widget.currentLocation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        markers: _markers.toSet(),
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: widget.currentLocation,
          zoom: 15,
        ),
      ),
    );
  }
}
