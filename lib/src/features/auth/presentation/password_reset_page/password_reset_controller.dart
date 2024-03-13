import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/features/auth/data/auth_repository.dart';

class PasswordResetController extends StateNotifier<AsyncValue<bool?>> {
  final AuthRepository authRepository;
  PasswordResetController({
    required this.authRepository,
  }) : super(const AsyncValue.data(null));

  Future<void> resetPassword(String password) async {
    state = const AsyncValue.loading();

    try {
      await authRepository.resetPassword(password);
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final passwordResetControllerProvider = StateNotifierProvider.autoDispose<
    PasswordResetController, AsyncValue<bool?>>(
  (ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    return PasswordResetController(
      authRepository: authRepository,
    );
  },
);
