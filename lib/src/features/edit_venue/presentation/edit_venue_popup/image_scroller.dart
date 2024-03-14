import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/features/add_venue/domain/venue_model.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/edit_venue_popup/edit_venue_popup_controller.dart';

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
  @override
  Widget build(BuildContext context) {
    var venueImagesState = ref.watch(
        editVenuePopupControllerProvider(widget.venue)
            .select((value) => value.venueImagesStatus));

    return venueImagesState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const Icon(Icons.error),
      data: (venueImages) {
        if (venueImages == null || venueImages.isEmpty) {
          debugPrint('No venue images found for ${widget.venue.name}');
          return const Icon(Icons.error);
        }
        return SizedBox(
            height: 250,
            child: PageView.builder(
                itemCount: venueImages.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Image(
                    image: venueImages[index],
                    fit: BoxFit.cover,
                  );
                }));
      },
    );
  }
}
