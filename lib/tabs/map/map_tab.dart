import 'package:flutter/material.dart';
import 'package:workwith_admin/tabs/map/map_widget.dart';
import 'package:workwith_admin/utils/map.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getCurrentLocation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data?.status == LocationServiceStatus.granted) {
            return MapWidget(currentLocation: snapshot.data!.location!);
          } else if (snapshot.data?.status ==
              LocationServiceStatus.serviceDisabled) {
            return const PermissionMessage(
                message:
                    'please enable location services in your device settings.');
          } else if (snapshot.data?.status ==
              LocationServiceStatus.permissionDenied) {
            return const PermissionMessage(
                message:
                    'Please allow permission to access location in your device settings.');
          } else if (snapshot.data?.status ==
              LocationServiceStatus.permissionDeniedForever) {
            return const PermissionMessage(
                message:
                    'Please allow permission to access location in your device settings.');
          }
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class PermissionMessage extends StatelessWidget {
  final String message;

  const PermissionMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(message)));
  }
}
