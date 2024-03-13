import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PermissionMessagePage extends StatelessWidget {
  final String message;
  final Function reload;

  const PermissionMessagePage(
      {super.key, required this.message, required this.reload});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  textAlign: TextAlign.center,
                  message,
                  style: const TextStyle(fontSize: 20),
                )),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Geolocator.openLocationSettings();
              },
              child: const Text("Open location settings"),
            ),
            const SizedBox(height: 16),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: TextButton(
            onPressed: () {
              reload();
            },
            child: const Text("Reload"),
          ),
        ),
      ],
    ));
  }
}
