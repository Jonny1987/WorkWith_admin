import 'package:flutter/material.dart';
import 'package:workwith_admin/src/features/add_venue/presentation/venue_search/venue_search_page.dart';
import 'package:workwith_admin/src/features/location_permissions_page/location_permissions_page.dart';

class AddVenueTab extends StatelessWidget {
  const AddVenueTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LocationPermissionsPage(
        createNextPage: () => const VenueSearchPage());
  }
}
