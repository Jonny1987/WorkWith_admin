import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/features/auth/data/auth_repository.dart';
import 'package:workwith_admin/utils/constants.dart';

class ProfileRepository {
  final AuthRepository authRepository;
  ProfileRepository({required this.authRepository});

  Future<void> signOut() async {
    return await supabase.auth.signOut();
  }

  String get currentUserId {
    return authRepository.currentUser.id;
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) {
    var authRepository = ref.watch(authRepositoryProvider);
    return ProfileRepository(authRepository: authRepository);
  },
);
