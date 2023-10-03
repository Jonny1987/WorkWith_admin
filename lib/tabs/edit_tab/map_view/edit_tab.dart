import 'package:flutter/material.dart';
import 'package:workwith_admin/tabs/edit_tab/map_view/map_view.dart';
import 'package:workwith_admin/tabs/edit_tab/venue_list_view.dart';

class EditTab extends StatefulWidget {
  const EditTab({Key? key}) : super(key: key);

  @override
  _EditTabState createState() => _EditTabState();
}

class _EditTabState extends State<EditTab> {
  final Widget _map_view = const VenueMapView();
  final Widget _list_view = const VenueListView();
  late Widget _currentView;
  late String _otherViewName;

  void _changeView() {
    setState(() {
      _currentView = _currentView == _map_view ? _list_view : _map_view;
      _otherViewName = _otherViewName == 'Map' ? 'List' : 'Map';
    });
  }

  @override
  void initState() {
    super.initState();
    _currentView = _map_view;
    _otherViewName = 'List';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
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
                      _currentView == _map_view ? Icons.list : Icons.map,
                      size: 24,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(7, 14, 14, 14),
                    child: Text('Show $_otherViewName',
                        style: TextStyle(fontSize: 18)),
                  ),
                ],
              )),
        ),
      ],
    ));
  }
}
