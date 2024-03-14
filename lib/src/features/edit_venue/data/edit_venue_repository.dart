import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workwith_admin/src/features/add_venue/domain/venue_photo_model.dart';
import 'package:workwith_admin/src/features/add_venue/domain/venue_model.dart';
import 'package:workwith_admin/src/features/edit_venue/application/google_photos_service.dart';
import 'package:workwith_admin/utils/constants.dart';
import 'package:image/image.dart';

class EditVenueRepository {
  final GooglePhotosService googlePhotosService;
  EditVenueRepository({required this.googlePhotosService});

  Future<List<Venue>> fetchVenues(Position currentPosition) async {
    final List<dynamic> data =
        await supabase.rpc('nearby_venues_admin', params: {
      'current_lat': currentPosition.latitude,
      'current_long': currentPosition.longitude,
    });
    print('data: $data');
    List<Venue> venues = [for (var venueMap in data) Venue.fromMap(venueMap)];
    return venues;
  }

  Future<NetworkImage> _getSizedImageFromPath({
    required String path,
    required String updatedAt,
    int? width,
    int? height,
  }) async {
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
    return NetworkImage(imageUrl);
  }

  Future<NetworkImage> getVenueThumbnailFromPath(
      String path, String updatedAt) async {
    return _getSizedImageFromPath(
      path: path,
      updatedAt: updatedAt,
      width: 600,
      height: 360,
    );
  }

  Future<NetworkImage> getVenuePhotoFromPath(
      String path, String updatedAt) async {
    return _getSizedImageFromPath(
        path: path, updatedAt: updatedAt, height: 600);
  }

  Future<List<NetworkImage>> fetchVenuePhotosConcurrently(
      List<VenuePhoto> venuePhotos,
      {int limit = 1000}) async {
    int n = min(limit, venuePhotos.length);
    var sublist = venuePhotos.sublist(0, n);

    List<NetworkImage?> images = List.filled(n, null, growable: false);

    if (venuePhotos.isNotEmpty) {
      List<Future> allFutures = List.generate(
        n,
        (index) async {
          final venuePhoto = sublist[index];
          NetworkImage networkImage;
          if (venuePhoto.newGoogleImageUrl != null) {
            networkImage = NetworkImage(venuePhoto.newGoogleImageUrl!);
          } else {
            networkImage = await getVenuePhotoFromPath(
                venuePhoto.imagePath!, venuePhoto.updatedAt!);
          }
          images[index] = networkImage;
        },
      );
      // Wait for all the Futures to complete.
      await Future.wait(allFutures);
    }
    return images.whereType<NetworkImage>().toList();
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
    print('venues: $data');
    List<Venue> venues = [for (var venueMap in data) Venue.fromMap(venueMap)];
    return venues;
  }

  Future<void> updateVenue(Map<String, dynamic> fields) async {
    await supabase.rpc('update_venue', params: fields);
  }

  Future<void> updateNotes(int venueId, String notes) async {
    await supabase.rpc('update_venue_notes', params: {
      'venue_id': venueId,
      'notes': notes,
    });
  }

  void _addIdsToVenuePhotos(
      dynamic idsAndGoogleUrls, List<VenuePhoto> venuePhotos, int venueId) {
    Map<String, int> googleImageUrlToId = {
      for (var map in idsAndGoogleUrls) map['google_image_url']: map['id']
    };
    for (var i = 0; i < venuePhotos.length; i++) {
      if (venuePhotos[i].id == null) {
        var id = googleImageUrlToId[venuePhotos[i].newGoogleImageUrl];
        if (id == null) {
          throw Exception('id is null');
        }
        venuePhotos[i] =
            venuePhotos[i].copyWith(id: id, imagePath: '$venueId/$id');
      }
    }
  }

  Future<void> updateVenuePhotosConcurrently(
      int venueId, List<VenuePhoto> venuePhotos) async {
    List<Future> allFutures = [];
    var idsAndGoogleUrls = await _updateVenuePhotoTable(venueId, venuePhotos);
    _addIdsToVenuePhotos(idsAndGoogleUrls, venuePhotos, venueId);
    venuePhotos.forEach((venuePhoto) {
      allFutures.add(_updateVenueImage(venueId, venuePhoto));
    });
    await Future.wait(allFutures);
  }

  String _getMimeType(Uint8List bytes) {
    var decode_order = [decodeJpg, decodePng, decodeGif];
    for (var func in decode_order) {
      try {
        func(bytes);
        return func == decodeJpg
            ? 'image/jpg'
            : func == decodePng
                ? 'image/png'
                : 'image/gif';
      } catch (e) {
        if (func == decodeGif) {
          throw e;
        }
      }
    }
    throw Exception('Failed to get mime type');
  }

  Future<void> _updateVenueImage(int venueId, VenuePhoto venuePhoto) async {
    if (venuePhoto.newGoogleImageUrl == null) {
      return;
    }
    var fullImageUrl =
        googlePhotosService.createFullImageUrl(venuePhoto.newGoogleImageUrl!);
    var imageProvider = NetworkImage(fullImageUrl);
    final bytes = await googlePhotosService.getImageBytes(imageProvider);
    var mime = _getMimeType(bytes);
    await supabase.storage.from('venue_images').uploadBinary(
          venuePhoto.imagePath!,
          bytes,
          fileOptions: FileOptions(
            contentType: mime,
            upsert: true,
          ),
        );
    debugPrint('uploaded venue photo');
  }

  Future<dynamic> _updateVenuePhotoTable(
      int venueId, List<VenuePhoto> venuePhotos) async {
    var venuePhotosData = venuePhotos.map((venuePhoto) {
      Map<String, dynamic> json = {
        'position': venuePhoto.position,
      };
      if (venuePhoto.newGoogleImageUrl != null) {
        json['google_image_url'] = venuePhoto.newGoogleImageUrl;
      }
      if (venuePhoto.isVisitorImage != null) {
        json['is_visitor_image'] = venuePhoto.isVisitorImage!;
      }
      if (venuePhoto.id != null) {
        json['id'] = venuePhoto.id;
      }
      return json;
    }).toList();
    var toUpdate = venuePhotosData
        .where((venuePhoto) => venuePhoto['id'] != null)
        .toList();
    toUpdate.sort((a, b) => b['position'] - a['position']);
    var toInsert = venuePhotosData
        .where((venuePhoto) => venuePhoto['id'] == null)
        .toList();
    await supabase
        .rpc('update_venue_photos', params: {'venue_photos_data': toUpdate});
    var idsAndGoogleUrls = await supabase.rpc('insert_venue_photos',
        params: {'venue_photos_data': toInsert, 'venue_id': venueId});
    return idsAndGoogleUrls;
  }
}

final editVenueRepositoryProvider = Provider<EditVenueRepository>((ref) {
  var googlePhotosService = ref.watch(googlePhotosServiceProvider);
  return EditVenueRepository(googlePhotosService: googlePhotosService);
});
