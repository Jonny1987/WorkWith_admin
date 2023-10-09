import 'package:flutter/material.dart';
import 'package:workwith_admin/tabs/edit_tab/map_view/map_view.dart';
import 'package:workwith_admin/tabs/edit_tab/venue_list_view.dart';

class EditTab extends StatefulWidget {
  const EditTab({Key? key}) : super(key: key);

  @override
  EditTabState createState() => EditTabState();
}

class EditTabState extends State<EditTab> with AutomaticKeepAliveClientMixin {
  final Widget _mapView = const VenuesMapView();
  final Widget _listView = const VenueListView();
  late Widget _currentView;
  late String _otherViewName;

  void _changeView() {
    setState(() {
      _currentView = _currentView == _mapView ? _listView : _mapView;
      _otherViewName = _otherViewName == 'Map' ? 'List' : 'Map';
    });
  }

  @override
  void initState() {
    super.initState();
    _currentView = _mapView;
    _otherViewName = 'List';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        _currentView,
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                )),
              ),
              onPressed: _changeView,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Icon(
                      _currentView == _mapView ? Icons.list : Icons.map,
                      size: 24,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(7, 14, 14, 14),
                    child: Text('Show $_otherViewName',
                        style: const TextStyle(fontSize: 18)),
                  ),
                ],
              )),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
