import 'package:flutter/material.dart';

class ChangeViewButton extends StatelessWidget {
  final Function() onChangeView;
  final Widget currentView;
  final String otherViewName;
  final Widget mapView;
  const ChangeViewButton(
      {Key? key,
      required this.onChangeView,
      required this.currentView,
      required this.otherViewName,
      required this.mapView})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          )),
        ),
        onPressed: onChangeView,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Icon(
                currentView == mapView ? Icons.list : Icons.map,
                size: 24,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 14, 14, 14),
              child: Text('Show $otherViewName',
                  style: const TextStyle(fontSize: 18)),
            ),
          ],
        ));
  }
}
