import 'package:flutter/widgets.dart';
import 'package:workwith_admin/src/features/auth/presentation/string_validators.dart';

final StringValidator emailSubmitValidator = EmailSubmitRegexValidator();
final StringValidator passwordRegisterSubmitValidator =
    MinLengthStringValidator(8);
final StringValidator passwordSignInSubmitValidator = NonEmptyStringValidator();
final StringValidator usernameSubmitValidator = UsernameSubmitRegexValidator();

String? emailErrorText(String email, BuildContext context) {
  final bool showErrorText = !emailSubmitValidator.isValid(email);
  final String errorText =
      email.isEmpty ? "Email can't be empty" : "Invalid email";
  return showErrorText ? errorText : null;
}

String _passwordErrorText(String password, BuildContext context) {
  String errorText = password.isEmpty
      ? "Password can't be empty"
      : "Password must be at least 8 characters";
  return errorText;
}

String? passwordRegisterErrorText(String password, BuildContext context) {
  final bool showErrorText = !passwordRegisterSubmitValidator.isValid(password);
  final String errorText = _passwordErrorText(password, context);
  return showErrorText ? errorText : null;
}

String? passwordResetErrorText(
    String password, String password1, BuildContext context) {
  var errorText = passwordRegisterErrorText(password, context);
  if (errorText != null) {
    return errorText;
  }
  if (password != password1) {
    return "Passwords don't match";
  }
  return null;
}

String? passwordSignInErrorText(String password, BuildContext context) {
  final bool showErrorText = !passwordSignInSubmitValidator.isValid(password);
  final String errorText = _passwordErrorText(password, context);
  return showErrorText ? errorText : null;
}
