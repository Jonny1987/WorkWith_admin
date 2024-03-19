import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workwith_admin/src/features/add_venue/domain/venue_photo_change_model.dart';
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
    required String? updatedGoogleUrlAt,
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
    String imageUrl = supabase.storage
        .from('venue_images')
        .getPublicUrl(path, transform: transform);
    if (updatedGoogleUrlAt != null) {
      imageUrl = imageUrl + '&cacheBust=$updatedGoogleUrlAt';
    }
    return NetworkImage(imageUrl);
  }

  Future<NetworkImage> getVenueThumbnailFromPath(
      String path, String? updatedGoogleUrlAt) async {
    return _getSizedImageFromPath(
      path: path,
      updatedGoogleUrlAt: updatedGoogleUrlAt,
      width: 600,
      height: 360,
    );
  }

  Future<NetworkImage> getVenuePhotoFromPath(
      String path, String? updatedGoogleUrlAt) async {
    return _getSizedImageFromPath(
        path: path, updatedGoogleUrlAt: updatedGoogleUrlAt, height: 600);
  }

  Future<List<NetworkImage?>> fetchVenuePhotosConcurrently(
      List<VenuePhoto> venuePhotos,
      {int limit = 1000}) async {
    int n = min(limit, venuePhotos.length);
    var sublist = venuePhotos.sublist(0, n);

    List<NetworkImage?> images = List.filled(n, null, growable: true);

    if (venuePhotos.isNotEmpty) {
      List<Future> allFutures = List.generate(
        n,
        (index) async {
          final venuePhoto = sublist[index];
          NetworkImage networkImage;
          networkImage = await getVenuePhotoFromPath(
              venuePhoto.imagePath, venuePhoto.updatedGoogleUrlAt);
          images[index] = networkImage;
        },
      );
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
    print('venues: $data');
    List<Venue> venues = [for (var venueMap in data) Venue.fromMap(venueMap)];
    return venues;
  }

  Future<void> updateVenue(Map<String, dynamic> fields) async {
    await supabase.rpc('update_venue', params: fields);
  }

  Future<void> upsertNotes(int venueId, String notes) async {
    await supabase.rpc('upsert_venue_notes', params: {
      'venue_id': venueId,
      'notes': notes,
    });
  }

  // void _addIdsToVenuePhotos(
  //     dynamic idsAndImagePaths, List<VenuePhoto> venuePhotos) {
  //   Map<String, int> googleImageUrlToId = {
  //     for (var map in idsAndImagePaths)
  //       map['google_image_url']: map['image_path']
  //   };
  //   for (var i = 0; i < venuePhotos.length; i++) {
  //     if (venuePhotos[i].id == null) {
  //       var id = googleImageUrlToId[venuePhotos[i].newGoogleImageUrl];
  //       if (id == null) {
  //         throw Exception('id is null');
  //       }
  //       venuePhotos[i] =
  //           venuePhotos[i].copyWith(id: id, imagePath: '$venueId/$id');
  //     }
  //   }
  // }

  Future<List<VenuePhoto>> updateVenuePhotosConcurrently(
      int venueId, List<VenuePhotoChange?> venuePhotoChanges) async {
    venuePhotoChanges =
        venuePhotoChanges.where((change) => change != null).toList();
    List<Future> allFutures = [];
    List<VenuePhoto> newVenuePhotos =
        await _updateVenuePhotoTable(venueId, venuePhotoChanges);

    var changedGoogleUrls = venuePhotoChanges
        .where((change) => change!.googleImageUrl != null)
        .map((change) => change!.googleImageUrl)
        .toList();
    List<VenuePhoto> changedVenuePhotos = newVenuePhotos
        .where((photo) => changedGoogleUrls.contains(photo.googleImageUrl))
        .toList();

    changedVenuePhotos.forEach((venuePhoto) {
      allFutures.add(_updateVenueImage(venueId, venuePhoto));
    });
    await Future.wait(allFutures);
    return newVenuePhotos;
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

  Future<void> _updateVenueImage(
    int venueId,
    VenuePhoto venuePhoto,
  ) async {
    if (venuePhoto.googleImageUrl == null) {
      return;
    }
    var fullImageUrl =
        googlePhotosService.createFullImageUrl(venuePhoto.googleImageUrl!);
    var imageProvider = NetworkImage(fullImageUrl);
    final bytes = await googlePhotosService.getImageBytes(imageProvider);
    var mime = _getMimeType(bytes);
    await supabase.storage.from('venue_images').uploadBinary(
          venuePhoto.imagePath,
          bytes,
          fileOptions: FileOptions(
            contentType: mime,
            upsert: true,
          ),
        );
  }

  Future<List<VenuePhoto>> _updateVenuePhotoTable(
      int venueId, List<VenuePhotoChange?> venuePhotoChanges) async {
    var toUpdate = venuePhotoChanges
        .where((change) => change?.id != null)
        .map((changes) => changes!.toMap())
        .toList();
    var toInsert = venuePhotoChanges
        .where((change) => change?.id == null)
        .map((changes) => changes!.toMap())
        .toList();

    List<dynamic> newVenueImageData = [];

    if (toUpdate.isNotEmpty) {
      newVenueImageData =
          await supabase.rpc('update_and_get_venue_photos', params: {
        'venue_photos_data': toUpdate,
        'venue_id_param': venueId,
      });
      print('***************** updated');
      print('newVenueImageData: $newVenueImageData');
    }
    if (toInsert.isNotEmpty) {
      newVenueImageData =
          await supabase.rpc('insert_and_get_venue_photos', params: {
        'venue_photos_data': toInsert,
        'venue_id_param': venueId,
      });
      print('***************** inserted');
      print('newVenueImageData: $newVenueImageData');
    }

    List<VenuePhoto> venuePhotos = [
      for (var map in newVenueImageData) VenuePhoto.fromMap(map)
    ];

    return venuePhotos;
  }
}

final editVenueRepositoryProvider = Provider<EditVenueRepository>((ref) {
  var googlePhotosService = ref.watch(googlePhotosServiceProvider);
  return EditVenueRepository(googlePhotosService: googlePhotosService);
});
