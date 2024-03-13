import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/exceptions/app_exceptions.dart';
import 'package:workwith_admin/src/features/location_permissions_page/location_permissions_controller.dart';
import 'package:workwith_admin/src/features/location_permissions_page/permission_message_page.dart';

class LocationPermissionsPage extends ConsumerStatefulWidget {
  final Widget Function() createNextPage;
  const LocationPermissionsPage({super.key, required this.createNextPage});

  @override
  ConsumerState<LocationPermissionsPage> createState() => _AddVenueTabState();
}

class _AddVenueTabState extends ConsumerState<LocationPermissionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(locationPermissionsControllerProvider.notifier)
          .getLocationPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(locationPermissionsControllerProvider).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          data: (locationResult) {
            if (locationResult == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return widget.createNextPage();
          },
          error: (error, stackTrace) {
            if (error is AppException) {
              if (error is LocationPermissionException) {
                return PermissionMessagePage(
                  message: error.message,
                  reload: () {
                    ref
                        .read(locationPermissionsControllerProvider.notifier)
                        .getLocationPermission();
                  },
                );
              }
            }
            throw error;
          },
        );
  }
}
