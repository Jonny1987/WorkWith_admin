import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:work_with/utils/constants.dart';

class LocationResult {
  final LatLng? location;
  final LocationServiceStatus status;

  LocationResult({required this.location, required this.status});
}

enum LocationServiceStatus {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  granted
}

Future<LocationResult> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return LocationResult(
        location: null, status: LocationServiceStatus.serviceDisabled);
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return LocationResult(
          location: null, status: LocationServiceStatus.permissionDenied);
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return LocationResult(
        location: null, status: LocationServiceStatus.permissionDeniedForever);
  }

  // If permissions are granted, fetch the current location.
  Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);

  LatLng location = LatLng(position.latitude, position.longitude);
  print('****** currentLocation: $location');
  return LocationResult(
      location: location, status: LocationServiceStatus.granted);
}

Future<List<dynamic>> getVenues(LatLng _center) async {
  final data = await supabase.rpc('nearby_venues', params: {
    'lat': _center.latitude,
    'long': _center.longitude,
  });
  return data;
}
