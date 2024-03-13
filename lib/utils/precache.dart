import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImagePreloader {
  Future<void> precacheImageList(
      Iterable<ImageProvider> imageList, BuildContext context) async {
    List<Future> futures = [];
    for (var image in imageList) {
      futures.add(precacheImageUtil(image, context));
    }
    await Future.wait(futures);
  }

  Future<void> precacheImageUtil(ImageProvider image, BuildContext context) {
    return precacheImage(image, context);
  }
}

final imagePreloaderProvider = Provider((ref) => ImagePreloader());
