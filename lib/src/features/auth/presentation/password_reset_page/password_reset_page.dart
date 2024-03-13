import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workwith_admin/src/features/auth/presentation/email_password_validators.dart';
import 'package:workwith_admin/src/features/auth/presentation/login/password_textbox.dart';
import 'package:workwith_admin/src/features/auth/presentation/password_reset_page/password_reset_controller.dart';
import 'package:workwith_admin/src/routing/app_router.dart';
import 'package:workwith_admin/utils/async_value_ui.dart';
import 'package:workwith_admin/utils/constants.dart';

class PasswordResetPage extends ConsumerStatefulWidget {
  const PasswordResetPage({super.key});

  @override
  ConsumerState<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends ConsumerState<PasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _password1Key = GlobalKey<FormFieldState>();
  final _password2Key = GlobalKey<FormFieldState>();

  final _focusNode = FocusScopeNode();

  final _password1EditingController = TextEditingController();
  final _password2EditingController = TextEditingController();

  String get password1 => _password1EditingController.text;

  @override
  void dispose() {
    _focusNode.dispose();
    _password1EditingController.dispose();
    _password2EditingController.dispose();
    super.dispose();
  }

  void _password1EditingComplete() {
    var isValid = _password1Key.currentState!.validate();
    if (isValid) {
      _focusNode.nextFocus();
    }
  }

  void _password2EditingComplete() {
    var isValid = _password2Key.currentState!.validate();
    if (isValid) {
      ref
          .read(passwordResetControllerProvider.notifier)
          .resetPassword(password1);
    }
  }

  Future<void> _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      ref
          .read(passwordResetControllerProvider.notifier)
          .resetPassword(password1);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool?>>(
      passwordResetControllerProvider,
      (_, state) {
        state.showTopSnackbarOnError(context);
        state.whenData(
          (wasReset) {
            if (wasReset == true) {
              context.goNamed(AppRoute.home.name);
            }
          },
        );
      },
    );

    var state = ref.watch(passwordResetControllerProvider);

    return Scaffold(
      appBar: const TransparentAppBar(),
      body: Column(children: [
        FocusScope(
          node: _focusNode,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: formPadding,
              shrinkWrap: true,
              children: [
                PasswordTextbox(
                  formFieldKey: _password1Key,
                  passwordEditingController: _password1EditingController,
                  state: state,
                  textInputAction: TextInputAction.next,
                  validator: (password) =>
                      passwordRegisterErrorText(password, context),
                  onEditingComplete: _password1EditingComplete,
                ),
                formSpacer,
                PasswordTextbox(
                  formFieldKey: _password2Key,
                  passwordEditingController: _password2EditingController,
                  state: state,
                  textInputAction: TextInputAction.done,
                  validator: (password) =>
                      passwordResetErrorText(password, password1, context),
                  onEditingComplete: _password2EditingComplete,
                ),
                formSpacer,
                formSpacer,
                ElevatedButton(
                  onPressed: state.isLoading ? null : () => _resetPassword(),
                  child: state.isLoading
                      ? const CircularProgressIndicator()
                      : const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text("Reset Password",
                              style: TextStyle(fontSize: 20)),
                        ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
