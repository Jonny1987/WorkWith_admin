import 'package:flutter/material.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/map_widget/map_widget.dart';
import 'package:workwith_admin/src/features/location_permissions_page/location_permissions_page.dart';

class EditVenueMapView extends StatelessWidget {
  const EditVenueMapView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LocationPermissionsPage(
        createNextPage: () => const EditVenueMapWidget());
  }
}
