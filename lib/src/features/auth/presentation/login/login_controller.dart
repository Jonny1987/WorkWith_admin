import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/exceptions/app_exceptions.dart';
import 'package:workwith_admin/src/features/auth/data/auth_repository.dart';

class LoginController extends StateNotifier<AsyncValue<bool?>> {
  final AuthRepository authRepository;
  LoginController({
    required this.authRepository,
  }) : super(const AsyncValue.data(null));

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await authRepository.signIn(email, password);

      var user = authRepository.currentUser;
      if (!user.appMetadata.containsKey('is_admin') ||
          user.appMetadata['is_admin'] != true) {
        await authRepository.signOut();
        throw UserNotAdminException();
      }
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final loginControllerProvider =
    StateNotifierProvider.autoDispose<LoginController, AsyncValue<bool?>>(
        (ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return LoginController(
    authRepository: authRepository,
  );
});
