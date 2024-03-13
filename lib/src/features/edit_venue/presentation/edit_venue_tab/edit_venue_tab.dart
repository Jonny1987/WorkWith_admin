import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/features/add_venue/domain/venue_model.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/edit_venue_tab/change_view_button.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/edit_venue_tab/edit_venue_controller.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/map_view/map_view.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/list_view/list_view.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/map_widget/venue_thumbnails_controller.dart';

class EditVenueTab extends ConsumerStatefulWidget {
  const EditVenueTab({Key? key}) : super(key: key);

  @override
  ConsumerState<EditVenueTab> createState() => EditVenueTabState();
}

class EditVenueTabState extends ConsumerState<EditVenueTab>
    with AutomaticKeepAliveClientMixin {
  late Widget _mapView;
  late Widget _listView;
  Widget? _currentView;
  String _otherViewName = "List";

  void _changeView() {
    setState(() {
      _currentView = _currentView == _mapView ? _listView : _mapView;
      _otherViewName = _otherViewName == 'Map' ? 'List' : 'Map';
    });
  }

  void _createViews() async {
    _mapView = const EditVenueMapView();
    _listView = const EditVenueListView();
    _currentView = _mapView;
  }

  @override
  void initState() {
    super.initState();
    _createViews();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.watch(editVenueControllerProvider.notifier).getCurrentLocation();
    });
  }

  void getVenueThumbnails(List<Venue> venues) {
    for (var venue in venues) {
      ref
          .watch(venueThumbnailsControllerProvider(venue).notifier)
          .getVenueThumbnail(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    ref.listen(
        editVenueControllerProvider
            .select((value) => value.currentLocationStatus), (_, state) {
      state.whenData((currentLocation) {
        if (currentLocation != null) {
          ref
              .watch(editVenueControllerProvider.notifier)
              .getVenues(currentLocation);
        }
      });
    });

    ref.listen(
        editVenueControllerProvider.select((value) => value.venuesStatus),
        (_, state) {
      state.whenData((venues) {
        if (venues != null) {
          getVenueThumbnails(venues);
          _createViews();
        }
      });
    });

    if (_currentView == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          _currentView!,
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ChangeViewButton(
                onChangeView: _changeView,
                currentView: _currentView!,
                otherViewName: _otherViewName,
                mapView: _mapView,
              )),
        ],
      );
    }
  }

  @override
  bool get wantKeepAlive => true;
}
