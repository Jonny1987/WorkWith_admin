import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workwith_admin/src/features/add_venue/domain/venue_model.dart';
import 'package:workwith_admin/utils/constants.dart';

class EditVenueRepository {
  Future<List<Venue>> fetchVenues(Position currentPosition) async {
    final List<dynamic> data = await supabase.rpc('nearby_venues', params: {
      'lat': currentPosition.latitude,
      'long': currentPosition.longitude,
    });
    List<Venue> venues = [for (var venueMap in data) Venue.fromMap(venueMap)];
    return venues;
  }

  Future<ImageProvider> _getSizedImageFromPath(String path,
      {int? width, int? height}) async {
    if (width == null && height == null) {
      throw ArgumentError('Either width or height must be provided');
    }

    TransformOptions transform = TransformOptions(
      width: width,
      height: height,
      resize: ResizeMode.contain,
    );
    final String imageUrl = supabase.storage
        .from('venue_images')
        .getPublicUrl(path, transform: transform);

    File imageFile = await DefaultCacheManager().getSingleFile(imageUrl);
    Uint8List imageBytes = await imageFile.readAsBytes();
    return MemoryImage(imageBytes);
  }

  Future<ImageProvider> getVenueThumbnailFromPath(String path) async {
    return _getSizedImageFromPath(path, width: 600, height: 360);
  }

  Future<ImageProvider> getVenueImageFromPath(String path) async {
    return _getSizedImageFromPath(path, height: 1500);
  }

  Future<List<ImageProvider>> fetchVenueImagesConcurrently(Venue venue,
      {int limit = 1000}) async {
    List<Future> allFutures = [];

    List<ImageProvider> images = [];

    if (venue.imagePaths != null && venue.imagePaths!.isNotEmpty) {
      int n = min(limit, venue.imagePaths!.length);
      var sublist = venue.imagePaths!.sublist(0, n);
      sublist.forEach((path) {
        Future future = getVenueImageFromPath(path).then(
          (fetchedImage) {
            images.add(fetchedImage);
          },
        );
        // Add the created Future to the list.
        allFutures.add(future);
      });
      // Wait for all the Futures to complete.
      await Future.wait(allFutures);
    }
    return images;
  }

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

  Future<List<Venue>> getRecentVenues(int limit) async {
    final List<dynamic> data = await supabase.rpc(
        'recently_updated_venues_with_notes',
        params: {'row_limit': limit});
    List<Venue> venues = [for (var venueMap in data) Venue.fromMap(venueMap)];
    return venues;
  }

  Future<int> updateVenue(Map<String, dynamic> fields) async {
    final int newVenueId = await supabase.rpc('update_venue', params: fields);
    return newVenueId;
  }

  Future<void> updateNotes(int venueId, String notes) async {
    await supabase.rpc('update_venue_notes', params: {
      'venue_id': venueId,
      'notes': notes,
    });
  }
}

final editVenueRepositoryProvider = Provider<EditVenueRepository>((ref) {
  return EditVenueRepository();
});
