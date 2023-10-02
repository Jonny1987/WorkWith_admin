import 'package:flutter/material.dart';
import 'package:workwith_admin/tabs/map/edit_venue_popup.dart';
import 'package:workwith_admin/utils/map.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
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
