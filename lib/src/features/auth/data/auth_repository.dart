import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workwith_admin/src/exceptions/app_exceptions.dart';
import 'package:workwith_admin/utils/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRepository {
  Future<bool> usernameExists(String username) async {
    final result =
        await supabase.rpc('username_exists', params: {'username': username});
    return result;
  }

  Future<void> signIn(String email, String password) async {
    try {
      var res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('************ user: ${res.user}');
      return;
    } on AuthException catch (e) {
      if (e.message == "Email not confirmed") {
        throw EmailNotConfirmedException();
      } else if (e.message == "Invalid login credentials") {
        throw InvalidCredentialsException();
      } else {
        rethrow;
      }
    }
  }

  Future<void> signOut() async {
    return await supabase.auth.signOut();
  }

  Future<void> sendResetPasswordEmail(String email) async {
    await supabase.auth.resetPasswordForEmail(email,
        redirectTo: "io.supabase://workwith/password-reset");
  }

  Future<void> resetPassword(String password) async {
    await supabase.auth.updateUser(UserAttributes(password: password));
  }

  User get currentUser => supabase.auth.currentUser!;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});
