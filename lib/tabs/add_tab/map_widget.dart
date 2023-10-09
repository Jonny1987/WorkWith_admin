import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:workwith_admin/models/place_autocomplete.dart';
import 'package:workwith_admin/repository/places/places.dart';
import 'package:workwith_admin/tabs/add_tab/add_venue_popup.dart';

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
  FocusNode searchBoxFocusNode = FocusNode();
  final PlacesRepository _placesRepository = PlacesRepository();
  List<PlaceAutocomplete> _predictions = [];
  dynamic _placeDetails;

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

  void _selectPlace(String placeId) async {
    _placeDetails = await _placesRepository.placeDetails(placeId);
    LatLng position = LatLng(
      _placeDetails['location']['lat'],
      _placeDetails['location']['lng'],
    );
    setState(() {
      _predictions = [];
      _markers = {
        Marker(
          markerId: MarkerId(_placeDetails['placeId']),
          position: position,
          icon: BitmapDescriptor.defaultMarker,
        )
      };
      _searchController.clear();
      searchBoxFocusNode.unfocus();
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
    return Stack(children: [
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
              focusNode: searchBoxFocusNode,
              controller: _searchController,
              onChanged: (value) => searchPlaces(value),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                hintStyle: TextStyle(color: Colors.grey[800]),
                hintText: "Search for a hotel, cafe, resturant, etc.",
                fillColor: Colors.white,
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
                    _selectPlace(_predictions[index].placeId);
                  },
                ),
              );
            },
          ),
        ],
      ),
      Visibility(
          visible: _markers.isNotEmpty && !searchBoxFocusNode.hasFocus,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.black),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  )),
                ),
                onPressed: () => Navigator.of(context)
                    .push(AddVenuePopup.route(_placeDetails)),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text('Add Venue', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          )),
    ]);
  }
}
