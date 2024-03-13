import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:workwith_admin/models/place_autocomplete.dart';
import 'package:workwith_admin/utils/constants.dart';
import 'package:http/http.dart' as http;

class AddVenueRepository {
  Future<Position> getCurrentLocation(
      {required LocationAccuracy accuracy}) async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: accuracy,
    );
  }

  Future<LocationPermission> checkLocationPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<int> insertVenue(Map<String, dynamic> fields) async {
    final int newVenueId = await supabase.rpc('insert_venue', params: fields);
    return newVenueId;
  }

  Future<void> insertNotes(int venueId, String notes) async {
    await supabase.rpc('insert_venue_notes', params: {
      'venue_id': venueId,
      'notes': notes,
    });
  }

  Future<List<PlaceAutocomplete>> autocomplete(
      String input, LatLng location) async {
    final String placesKey = dotenv.env['ANDROID_MAPS_API_KEY']!;
    const String types = 'lodging|cafe|library|restaurant';
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$placesKey&types=$types&location=${location.latitude},${location.longitude}&radius=10000';
    final Map<String, String> headers = {
      'x-android-package': dotenv.env['ANDROID_PACKAGE_NAME']!,
      'x-android-cert': dotenv.env['ANDROID_MAPS_SHA1_FINGERPRINT']!,
    };
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
    final json = jsonDecode(response.body);
    final predictions = json['predictions'] as List<dynamic>;
    return predictions
        .map((prediction) => PlaceAutocomplete.fromMap(prediction))
        .toList();
  }

  Future<dynamic> placeDetails(String placeId) async {
    final String placesKey = dotenv.env['ANDROID_MAPS_API_KEY']!;
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$placesKey';
    final Map<String, String> headers = {
      'x-android-package': dotenv.env['ANDROID_PACKAGE_NAME']!,
      'x-android-cert': dotenv.env['ANDROID_MAPS_SHA1_FINGERPRINT']!,
    };
    final response = await http.get(Uri.parse(url), headers: headers);
    final json = jsonDecode(response.body);
    final data = json['result'];
    final result = {
      'name': data['name'],
      'location': data['geometry']['location'],
      'placeId': data['place_id'],
    };
    return result;
  }
}

final addVenueRepositoryProvider = Provider<AddVenueRepository>((ref) {
  return AddVenueRepository();
});
