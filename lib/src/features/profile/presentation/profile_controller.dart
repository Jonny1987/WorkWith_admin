import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/features/profile/data/profile_repository.dart';

class ProfileController extends StateNotifier<AsyncValue<bool?>> {
  final ProfileRepository profileRepository;
  ProfileController({required this.profileRepository})
      : super(const AsyncValue.data(null));

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await profileRepository.signOut();
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void resetProfileSignOutStatus() {
    state = const AsyncValue.data(null);
  }
}

final profileControllerProvider =
    StateNotifierProvider.autoDispose<ProfileController, AsyncValue<bool?>>(
  (ref) {
    var profileRepository = ref.watch(profileRepositoryProvider);
    return ProfileController(
      profileRepository: profileRepository,
    );
  },
);
