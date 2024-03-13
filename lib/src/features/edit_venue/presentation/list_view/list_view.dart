import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workwith_admin/src/features/edit_venue/presentation/edit_venue_tab/edit_venue_controller.dart';
import 'package:workwith_admin/src/routing/app_router.dart';

class EditVenueListView extends ConsumerStatefulWidget {
  const EditVenueListView({Key? key}) : super(key: key);

  @override
  ConsumerState<EditVenueListView> createState() => VenueListViewState();
}

class VenueListViewState extends ConsumerState<EditVenueListView> {
  @override
  Widget build(BuildContext context) {
    var venues = ref
        .watch(
            editVenueControllerProvider.select((value) => value.venuesStatus))
        .value;
    return Scaffold(
        body: ListView.builder(
            itemCount: venues!.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(venues[index].name),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () => context.pushNamed(AppRoute.editVenue.name,
                      extra: venues[index]),
                ),
              );
            }));
  }
}
