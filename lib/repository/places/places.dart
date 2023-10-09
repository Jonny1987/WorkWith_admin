import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:workwith_admin/models/place_autocomplete.dart';

class PlacesRepository {
  final String key = 'AIzaSyCoGjxV5QYOrorggrcfOLEiRvpUc9ujfDI';
  final String types = 'lodging|cafe|library|restaurant';

  Future<List<PlaceAutocomplete>> autocomplete(
      String input, LatLng location) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$key&types=$types&location=${location.latitude},${location.longitude}&radius=10000';
    final Map<String, String> headers = {
      'x-android-package': dotenv.env['ANDROID_PACKAGE_NAME']!,
      'x-android-cert': dotenv.env['ANDROID_MAPS_SHA1_FINGERPRINT']!,
    };
    final response = await http.get(Uri.parse(url), headers: headers);
    final json = jsonDecode(response.body);
    final predictions = json['predictions'] as List<dynamic>;
    return predictions
        .map((prediction) => PlaceAutocomplete.fromMap(prediction))
        .toList();
  }

  Future<dynamic> placeDetails(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';
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
