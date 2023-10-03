import 'package:flutter/material.dart';
import 'package:workwith_admin/tabs/edit_tab/edit_venue_popup.dart';
import 'package:workwith_admin/utils/map.dart';

class VenueListView extends StatefulWidget {
  const VenueListView({Key? key}) : super(key: key);

  @override
  _VenueListViewState createState() => _VenueListViewState();
}

class _VenueListViewState extends State<VenueListView> {
  List<dynamic> _venues = [];

  void _updateVenues() async {
    final List<dynamic> venues = await getRecentVenues(20);
    setState(() {
      _venues = venues;
    });
  }

  @override
  void initState() {
    super.initState();
    _updateVenues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
            itemCount: _venues.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_venues[index]['name']),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => Navigator.of(context)
                    .push(EditVenuePopup.route(_venues[index]['id'])),
              );
            }));
  }
}
