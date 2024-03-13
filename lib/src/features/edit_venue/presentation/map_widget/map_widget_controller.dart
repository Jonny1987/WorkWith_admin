import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:workwith_admin/src/features/add_venue/domain/venue_model.dart';
import 'package:workwith_admin/src/features/edit_venue/data/edit_venue_repository.dart';
import 'package:workwith_admin/src/routing/app_router.dart';

class EditVenueMapWidgetController
    extends StateNotifier<AsyncValue<Set<Marker>?>> {
  final EditVenueRepository editVenueRepository;
  EditVenueMapWidgetController({required this.editVenueRepository})
      : super(const AsyncValue.data(null));

  void createMarkers(List<Venue> venues, BuildContext context) async {
    state = const AsyncValue.loading();
    try {
      final markers = venues.map((venue) {
        return Marker(
          markerId: MarkerId(venue.id.toString()),
          position: LatLng(venue.lat, venue.long),
          infoWindow: InfoWindow(
            title: venue.name,
            onTap: () =>
                context.pushNamed(AppRoute.editVenue.name, extra: venue),
          ),
          icon: BitmapDescriptor.defaultMarker,
        );
      }).toSet();
      state = AsyncValue.data(markers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final editVenueMapWidgetControllerProvider = StateNotifierProvider.autoDispose<
    EditVenueMapWidgetController, AsyncValue<Set<Marker>?>>(
  (ref) {
    return EditVenueMapWidgetController(
        editVenueRepository: ref.watch(editVenueRepositoryProvider));
  },
);
