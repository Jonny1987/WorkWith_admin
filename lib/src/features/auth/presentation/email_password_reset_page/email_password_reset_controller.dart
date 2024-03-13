import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/features/auth/data/auth_repository.dart';

class EmailPasswordResetController extends StateNotifier<AsyncValue<bool?>> {
  final AuthRepository authRepository;
  EmailPasswordResetController({
    required this.authRepository,
  }) : super(const AsyncValue.data(null));

  Future<void> sendResetPasswordEmail(String email) async {
    state = const AsyncValue.loading();

    try {
      await authRepository.sendResetPasswordEmail(email);
      state = const AsyncValue.data(true);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final emailPasswordResetControllerProvider = StateNotifierProvider.autoDispose<
    EmailPasswordResetController, AsyncValue<bool?>>(
  (ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    return EmailPasswordResetController(
      authRepository: authRepository,
    );
  },
);
