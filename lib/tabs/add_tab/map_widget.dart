import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:workwith_admin/models/place_autocomplete.dart';
import 'package:workwith_admin/repository/places/places.dart';

class AddMapWidget extends StatefulWidget {
  final LatLng currentLocation;
  const AddMapWidget({super.key, required this.currentLocation});

  @override
  State<AddMapWidget> createState() => _AddMapWidgetState();
}

class _AddMapWidgetState extends State<AddMapWidget> {
  CameraPosition? cameraPosition;
  Set<Marker> _markers = {};
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();
  final PlacesRepository _placesRepository = PlacesRepository();
  List<PlaceAutocomplete> _predictions = [];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  initState() {
    super.initState();
    cameraPosition = CameraPosition(
      target: widget.currentLocation,
      zoom: 15,
    );
  }

  void searchPlaces(String searchValue) async {
    if (searchValue.isNotEmpty) {
      List<PlaceAutocomplete> results = await _placesRepository.autocomplete(
          searchValue, widget.currentLocation);
      setState(() {
        _predictions = results;
      });
    } else {
      setState(() {
        _predictions = [];
      });
    }
  }

  void _placeDetails(BuildContext context, String placeId) async {
    dynamic result = await _placesRepository.placeDetails(placeId);
    LatLng position = LatLng(
      result['location']['lat'],
      result['location']['lng'],
    );
    setState(() {
      _predictions = [];
      _markers = {
        Marker(
          markerId: MarkerId(result['placeId']),
          position: position,
          icon: BitmapDescriptor.defaultMarker,
        )
      };
      _searchController.clear();
      FocusScope.of(context).unfocus();
      mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 15,
        ),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
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
            target: widget.currentLocation,
            zoom: 15,
          ),
          myLocationButtonEnabled: true,
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => searchPlaces(value),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  filled: true,
                  hintStyle: TextStyle(color: Colors.grey[800]),
                  hintText: "Search for a hotel, cafe, resturant, etc.",
                  fillColor: Colors.white70,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.white,
                  child: ListTile(
                    title: Text(_predictions[index].description),
                    onTap: () {
                      _placeDetails(context, _predictions[index].placeId);
                    },
                  ),
                );
              },
            ),
          ],
        )
      ]),
    );
  }
}
