import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/features/add_venue/domain/venue_model.dart';
import 'package:workwith_admin/src/features/add_venue/domain/venue_photo_model.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/edit_venue_popup/edit_venue_popup_controller.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/edit_venue_popup/image_button.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/google_image_selector/google_photo_selector.dart';

class ImageScroller extends ConsumerStatefulWidget {
  final Venue venue;
  const ImageScroller({
    super.key,
    required this.venue,
  });

  @override
  ConsumerState<ImageScroller> createState() => ImageScrollerState();
}

class ImageScrollerState extends ConsumerState<ImageScroller> {
  late PageController pageController;
  int currentIndex = 0;
  late List<VenuePhoto> venuePhotos;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    pageController.removeListener(_onPageChanged);
    pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    currentIndex = pageController.page!.round();
    setState(() {});
  }

  void openGoogleSelector(Function onSelectImage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GooglePhotoSelector(
          placeDataId: widget.venue.googlePlaceDataId,
          venueImageIndex: currentIndex,
          onSelectImage: onSelectImage,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
        editVenuePopupControllerProvider(widget.venue)
            .select((value) => value.editedVenuePhotosStatus), (_, state) {
      state.whenData((editedVenuePhotos) {
        if (editedVenuePhotos != null) {
          ref
              .read(editVenuePopupControllerProvider(widget.venue).notifier)
              .getVenueImageProviders(context);
        }
      });
    });
    var venuePhotosState = ref.watch(
        editVenuePopupControllerProvider(widget.venue)
            .select((value) => value.venueImageProvidersStatus));

    var editedVenuePhotos = ref
        .read(editVenuePopupControllerProvider(widget.venue)
            .select((value) => value.editedVenuePhotosStatus))
        .value;

    return venuePhotosState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        return const Icon(Icons.error);
      },
      data: (venuePhotoProviders) {
        if (venuePhotoProviders == null || venuePhotoProviders.isEmpty) {
          debugPrint('No venue images found for ${widget.venue.name}');
          return const Icon(Icons.error);
        }
        return SizedBox(
          height: 250,
          child: Stack(
            children: [
              PageView.builder(
                controller: pageController,
                itemCount: venuePhotoProviders.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  if (editedVenuePhotos![index].newGoogleImageUrl != null) {
                    print(
                        'displaying newGoogleImageUrl: ${editedVenuePhotos[index].newGoogleImageUrl}');
                  } else {
                    print(
                        'displaying venuePhotoProviders: ${venuePhotoProviders[index].url}');
                  }
                  return Image(
                    image: editedVenuePhotos[index].newGoogleImageUrl != null
                        ? NetworkImage(
                            editedVenuePhotos[index].newGoogleImageUrl!)
                        : venuePhotoProviders[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: ImageButton(
                    onPressed: () => openGoogleSelector(
                          ref
                              .read(
                                  editVenuePopupControllerProvider(widget.venue)
                                      .notifier)
                              .replaceVenuePhoto,
                        ),
                    text: 'R'),
              ),
              Positioned(
                top: 8,
                right: 70,
                child: ImageButton(
                    onPressed: () => openGoogleSelector(
                          ref
                              .read(
                                  editVenuePopupControllerProvider(widget.venue)
                                      .notifier)
                              .insertVenuePhoto,
                        ),
                    text: 'I'),
              ),
              if (editedVenuePhotos![currentIndex].wasUpdated == false)
                Positioned(
                  top: 8,
                  right: 132,
                  child: ImageButton(
                      onPressed: () => ref
                          .read(editVenuePopupControllerProvider(widget.venue)
                              .notifier)
                          .unstageVenuePhoto(currentIndex),
                      icon: Icons.undo),
                ),
            ],
          ),
        );
      },
    );
  }
}
