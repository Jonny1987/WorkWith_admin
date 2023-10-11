import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:workwith_admin/tabs/edit_tab/map_view/map_widget.dart';
import 'package:workwith_admin/utils/map.dart';

class VenuesMapView extends StatefulWidget {
  const VenuesMapView({super.key});

  @override
  State<VenuesMapView> createState() => _VenuesMapViewState();
}

class _VenuesMapViewState extends State<VenuesMapView> {
  void reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocationResult>(
      future: getCurrentLocation(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
              child: Text('${snapshot.error}: ${snapshot.stackTrace}'));
        }
        print(
            '****************** Connection state: ${snapshot.connectionState}');
        if (snapshot.connectionState == ConnectionState.done) {
          print('****************** Connection state done.');
          if (snapshot.data?.status == LocationServiceStatus.granted) {
            print('****************** Location permissions granted.');
            return VenuesMapWidget(currentLocation: snapshot.data!.location!);
          } else if (snapshot.data?.status ==
              LocationServiceStatus.serviceDisabled) {
            print('****************** Location services disabled.');
            return PermissionMessage(
                message:
                    'Please enable location services in your device settings and then reload.',
                reload: reload);
          } else if (snapshot.data?.status ==
                  LocationServiceStatus.permissionDenied ||
              snapshot.data?.status ==
                  LocationServiceStatus.permissionDeniedForever) {
            print('****************** Location permissions denied.');
            return PermissionMessage(
                message:
                    'Please allow permission to access location in your device settings and then reload.',
                reload: reload);
          }
        }
        print('Loading...');
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class PermissionMessage extends StatelessWidget {
  final String message;
  Function reload;

  PermissionMessage({super.key, required this.message, required this.reload});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              textAlign: TextAlign.center,
              message,
              style: TextStyle(fontSize: 20),
            )),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Geolocator.openLocationSettings();
          },
          child: const Text('Open location settings'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            reload();
          },
          child: const Text('Reload'),
        )
      ],
    ));
  }
}
