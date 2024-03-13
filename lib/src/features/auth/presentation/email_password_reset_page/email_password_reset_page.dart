import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/features/auth/presentation/email_password_reset_page/email_password_reset_controller.dart';
import 'package:workwith_admin/src/features/auth/presentation/login/email_textbox.dart';
import 'package:workwith_admin/utils/async_value_ui.dart';
import 'package:workwith_admin/utils/constants.dart';

class EmailPasswordResetPage extends ConsumerStatefulWidget {
  const EmailPasswordResetPage({super.key});

  @override
  ConsumerState<EmailPasswordResetPage> createState() =>
      _EmailPasswordResetPageState();
}

class _EmailPasswordResetPageState
    extends ConsumerState<EmailPasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormFieldState>();

  final _focusNode = FocusScopeNode();

  final _emailEditingController = TextEditingController();

  String get email => _emailEditingController.text;

  @override
  void dispose() {
    _focusNode.dispose();
    _emailEditingController.dispose();
    super.dispose();
  }

  void _emailEditingComplete() {
    var isValid = _emailKey.currentState!.validate();
    if (isValid) {
      ref
          .read(emailPasswordResetControllerProvider.notifier)
          .sendResetPasswordEmail(email);
    }
  }

  Future<void> _sendResetPasswordEmail() async {
    var isValid = _formKey.currentState!.validate();
    if (isValid) {
      ref
          .read(emailPasswordResetControllerProvider.notifier)
          .sendResetPasswordEmail(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool?>>(emailPasswordResetControllerProvider,
        (_, state) {
      state.showTopSnackbarOnError(context);
    });

    var state = ref.watch(emailPasswordResetControllerProvider);

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
                EmailTextbox(
                  formFieldKey: _emailKey,
                  emailEditingController: _emailEditingController,
                  state: state,
                  textInputAction: TextInputAction.next,
                  onEditingComplete: _emailEditingComplete,
                ),
                formSpacer,
                formSpacer,
                ElevatedButton(
                  onPressed: state.isLoading == true
                      ? null
                      : () => _sendResetPasswordEmail(),
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
        if (state.value != null)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              "Instructions to reset your password have been sent to your email address",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                color: Colors.green,
              ),
            ),
          ),
      ]),
    );
  }
}
