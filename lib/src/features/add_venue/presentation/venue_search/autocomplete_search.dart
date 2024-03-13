import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:workwith_admin/models/place_autocomplete.dart';
import 'package:workwith_admin/src/features/add_venue/data/add_venue_repository.dart';

class AutoCompleteSearch extends ConsumerStatefulWidget {
  final LatLng currentLocation;
  final Function onSelect;

  const AutoCompleteSearch({
    Key? key,
    required this.currentLocation,
    required this.onSelect,
  }) : super(key: key);

  @override
  ConsumerState<AutoCompleteSearch> createState() => _AutoCompleteSearchState();
}

class _AutoCompleteSearchState extends ConsumerState<AutoCompleteSearch> {
  List<PlaceAutocomplete> _predictions = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchBoxFocusNode = FocusNode();

  void searchPlaces(String searchValue, WidgetRef ref) async {
    if (searchValue.isNotEmpty) {
      List<PlaceAutocomplete> results = await ref
          .read(addVenueRepositoryProvider)
          .autocomplete(searchValue, widget.currentLocation);
      print('results: $results');
      setState(() {
        _searchController.clear();
        _predictions = results;
      });
    } else {
      setState(() {
        _predictions = [];
      });
    }
  }

  void _selectPlace(String placeId) {
    setState(() {
      _searchController.clear();
      _searchBoxFocusNode.unfocus();
      _predictions = [];
    });
    widget.onSelect(placeId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: TextField(
            focusNode: _searchBoxFocusNode,
            controller: _searchController,
            onChanged: (value) => searchPlaces(value, ref),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              filled: true,
              hintStyle: TextStyle(color: Colors.grey[800]),
              hintText: "Search for a hotel, cafe, resturant, etc.",
              fillColor: Colors.white,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: _predictions.length,
          itemBuilder: (context, index) {
            return Container(
              color: Colors.white,
              child: ListTile(
                title: Text(_predictions[index].description),
                onTap: () {
                  _selectPlace(_predictions[index].placeId);
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
