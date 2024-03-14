import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class GooglePhotosService {
  String _changeUrlWidth(String originalUrl, int width) {
    final RegExp pattern = RegExp(r'=w\d+(-h\d+)?');
    final String replacement = '=w$width';

    return originalUrl.replaceAllMapped(pattern, (Match match) => replacement);
  }

  String createFullImageUrl(String url) {
    return _changeUrlWidth(url, 1200);
  }

  String createThumbnailImageUrl(String url) {
    return _changeUrlWidth(url, 600);
  }

  Future<Uint8List> getImageBytes(ImageProvider provider) async {
    final ImageStream stream = provider.resolve(ImageConfiguration.empty);
    final Completer<ui.Image> completer = Completer<ui.Image>();
    late ImageStreamListener listener;

    listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        completer.complete(info.image);
        stream.removeListener(listener);
      },
      onError: (dynamic error, StackTrace? stackTrace) {
        completer.completeError(error, stackTrace);
        stream.removeListener(listener);
      },
    );

    stream.addListener(listener);
    final ui.Image image = await completer.future;
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw Exception('Failed to get image bytes');
    }
    return byteData.buffer.asUint8List();
  }
}

final googlePhotosServiceProvider = Provider<GooglePhotosService>((ref) {
  return GooglePhotosService();
});
