import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/exceptions/app_exceptions.dart';
import 'package:workwith_admin/src/features/edit_venue/domain/google_photos_page_model.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/google_image_selector/category_enum.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/google_image_selector/google_photo_selector_controller.dart';

class GooglePhotoSelector extends ConsumerStatefulWidget {
  final String placeDataId;
  final int venuePhotoIndex;
  final int? venuePhotoId;
  final Function onSelectPhoto;
  const GooglePhotoSelector({
    Key? key,
    required this.placeDataId,
    required this.venuePhotoIndex,
    this.venuePhotoId,
    required this.onSelectPhoto,
  }) : super(key: key);

  @override
  ConsumerState<GooglePhotoSelector> createState() =>
      _GooglePhotoSelectorState();
}

class _GooglePhotoSelectorState extends ConsumerState<GooglePhotoSelector> {
  final ScrollController _scrollController = ScrollController();
  String? nextPageToken;
  int _selectedPhotoIndex = -1;
  final List<bool> loadedImages = [];

  final categoryIdPreference = [
    GooglePhotoCategory.vibe,
    GooglePhotoCategory.byOwner,
    GooglePhotoCategory.fromVisitors
  ];
  int currentCategoryIndex = 0;

  String getCategory() {
    return categoryIdPreference[currentCategoryIndex].categoryId;
  }

  void getNextPhotosPage() {
    if (currentCategoryIndex >= categoryIdPreference.length) {
      return;
    }
    ref
        .read(
            googlePhotoSelectorControllerProvider(widget.placeDataId).notifier)
        .getVenueGooglePhotos(
          nextPageToken: nextPageToken,
          categoryId: getCategory(),
        );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getNextPhotosPage();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        var results = ref
            .read(googlePhotoSelectorControllerProvider(widget.placeDataId))
            .value!;

        if (results.googlePhotos.length >= 10) {
          if (results.nextPageToken == null) {
            currentCategoryIndex++;
          }
          getNextPhotosPage();
        }
        ;
      }
    });
  }

  bool _allPreviousImagesLoaded(int index) {
    for (int i = 0; i <= index; i++) {
      if (!loadedImages[i]) {
        return false;
      }
    }
    return true;
  }

  void _loadImage(int index, GooglePhotosResults googlePhotosPage) {
    NetworkImage(googlePhotosPage.googlePhotos[index].thumbnailUrl)
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener(
            (ImageInfo image, bool synchronousCall) {
              print(
                  'Image loaded: ${googlePhotosPage.googlePhotos[index].thumbnailUrl}');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  print('Setting loadedImages[$index] to true');
                  setState(() {
                    loadedImages[index] = true;
                  });
                }
              });
            },
            onError: (exception, stackTrace) {
              print('exception: $exception');
              // Mark the image as loaded to prevent blocking other images from displaying
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    loadedImages[index] = true;
                  });
                }
              });
            },
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    var state =
        ref.watch(googlePhotoSelectorControllerProvider(widget.placeDataId));

    return state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          if (error is GooglePhotosNoPhotosFound) {
            print('**************** No photos found');
            WidgetsBinding.instance.addPostFrameCallback((_) {
              currentCategoryIndex++;
              getNextPhotosPage();
            });
          }
          return const Icon(Icons.error);
        },
        data: (googlePhotosPage) {
          if (googlePhotosPage == null ||
              googlePhotosPage.googlePhotos.isEmpty) {
            debugPrint('No venue images found');
            return const Icon(Icons.error);
          }

          // this will also be true for empty list
          if (loadedImages.every((isLoaded) => isLoaded)) {
            // checking loadedImages length as we don't wanto get get next page
            // until first pages thumbnails has loaded
            if (googlePhotosPage.googlePhotos.length < 10 &&
                loadedImages.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                currentCategoryIndex++;
                getNextPhotosPage();
              });
            }
            var numNewPhotos =
                googlePhotosPage.googlePhotos.length - loadedImages.length;
            // so we add new elements to loadedImages at teh start and whenever a
            // previous page's thumbails have been fully loaded
            if (numNewPhotos > 0) {
              var newLoadedImages = List.filled(numNewPhotos, false);
              loadedImages.addAll(newLoadedImages);
            }
          }

          return Dialog(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 15, 8, 0),
                    child: ListView.builder(
                      key: const PageStorageKey<String>('photosList'),
                      itemCount: googlePhotosPage.googlePhotos.length,
                      itemBuilder: (context, index) {
                        if (!loadedImages[index]) {
                          _loadImage(index, googlePhotosPage);
                        }
                        bool allPreviousLoaded =
                            _allPreviousImagesLoaded(index);

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedPhotoIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _selectedPhotoIndex == index
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: allPreviousLoaded
                                ? Image.network(
                                    googlePhotosPage
                                        .googlePhotos[index].thumbnailUrl,
                                    fit: BoxFit.cover)
                                : const Center(
                                    child: CircularProgressIndicator()),
                          ),
                        );
                      },
                      controller: _scrollController,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ElevatedButton(
                    child: const Text('Select'),
                    onPressed: () {
                      if (_selectedPhotoIndex >= 0) {
                        widget.onSelectPhoto(
                          widget.venuePhotoIndex,
                          widget.venuePhotoId,
                          googlePhotosPage.googlePhotos[_selectedPhotoIndex],
                        );
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }
}
