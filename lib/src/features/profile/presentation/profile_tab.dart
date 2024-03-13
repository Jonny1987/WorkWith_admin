import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workwith_admin/src/features/profile/presentation/profile_controller.dart';
import 'package:workwith_admin/src/routing/app_router.dart';
import 'package:workwith_admin/utils/constants.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  @override
  Widget build(BuildContext context) {
    var profileController = ref.read(profileControllerProvider.notifier);

    ref.listen<AsyncValue<bool?>>(profileControllerProvider, (_, state) {
      state.whenData((signOutStatus) {
        if (signOutStatus == true) {
          profileController.resetProfileSignOutStatus();
          context.goNamed(AppRoute.login.name);
        }
      });
    });
    return Scaffold(
      appBar: const TransparentAppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        children: [
          ElevatedButton(
              onPressed: ref.read(profileControllerProvider.notifier).signOut,
              child: const Text('Sign Out')),
        ],
      ),
    );
  }
}
