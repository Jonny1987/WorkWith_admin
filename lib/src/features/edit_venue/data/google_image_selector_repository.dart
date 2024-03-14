import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:workwith_admin/src/exceptions/app_exceptions.dart';
import 'package:workwith_admin/src/features/edit_venue/application/google_photos_service.dart';
import 'package:workwith_admin/src/features/edit_venue/domain/google_photos_page_model.dart';

class GoogleImageSelectorRepository {
  final GooglePhotosService googlePhotosService;
  GoogleImageSelectorRepository({required this.googlePhotosService});

  final apiKey = dotenv.env['SERPAPI_API_KEY'];
  final baseApiUrl = 'https://serpapi.com/search';
  final engine = 'google_maps_photos';

  Future<GooglePhotosResults> getVenuePhotos({
    required String dataId,
    required String categoryId,
    String? nextPageToken,
  }) async {
    var queryParameters = {
      'engine': engine,
      'api_key': apiKey,
      'data_id': dataId,
      'category_id': categoryId,
    };
    if (nextPageToken != null) {
      queryParameters['next'] = nextPageToken;
    }
    Uri url = Uri.parse(baseApiUrl).replace(queryParameters: queryParameters);
    print(url);

    var response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception(
          'Failed to load venue photos: ${response.statusCode}, ${response.body}');
    }

    Map<String, dynamic> data = jsonDecode(response.body);

    if (data['photos'] == null) {
      throw GooglePhotosNoPhotosFound();
    }
    data['thumbnails'] = List<String>.from(
      data['photos'].map<String>(
        (photoJson) =>
            googlePhotosService.createThumbnailImageUrl(photoJson['image']),
      ),
    );
    data['category_id'] = categoryId;

    var googlePhotos = GooglePhotosResults.fromMap(data);
    return googlePhotos;
  }
}

final googleImageSelectorRepositoryProvider =
    Provider<GoogleImageSelectorRepository>(
  (ref) {
    var service = ref.watch(googlePhotosServiceProvider);
    return GoogleImageSelectorRepository(googlePhotosService: service);
  },
);
