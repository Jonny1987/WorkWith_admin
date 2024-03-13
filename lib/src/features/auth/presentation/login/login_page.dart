import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workwith_admin/src/features/auth/presentation/email_password_validators.dart';
import 'package:workwith_admin/src/features/auth/presentation/login/email_textbox.dart';
import 'package:workwith_admin/src/features/auth/presentation/login/login_controller.dart';
import 'package:workwith_admin/src/features/auth/presentation/login/password_textbox.dart';
import 'package:workwith_admin/src/features/auth/presentation/password_reset_page/password_reset_controller.dart';
import 'package:workwith_admin/src/routing/app_router.dart';
import 'package:workwith_admin/utils/async_value_ui.dart';
import 'package:workwith_admin/utils/constants.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormFieldState>();
  final _passwordKey = GlobalKey<FormFieldState>();

  final _focusNode = FocusScopeNode();

  final _emailEditingController = TextEditingController();
  final _passwordEditingController = TextEditingController();

  String get email => _emailEditingController.text;
  String get password => _passwordEditingController.text;

  Future<void> _signIn(String email, String password) async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    var loginController = ref.read(loginControllerProvider.notifier);
    await loginController.signIn(email, password);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final passwordWasReset = ref.read(passwordResetControllerProvider).value;
      if (passwordWasReset != null) {
        context.showSuccessMessage(
            context, "Your password was successfully reset. Please login");
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _emailEditingController.dispose();
    _passwordEditingController.dispose();
    super.dispose();
  }

  void _emailEditingComplete() {
    var isValid = _emailKey.currentState!.validate();
    if (isValid) {
      _focusNode.nextFocus();
    }
  }

  void _passwordEditingComplete() {
    var isValid = _passwordKey.currentState!.validate();
    if (isValid) {
      _signIn(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool?>>(loginControllerProvider, (_, state) {
      state.showTopSnackbarOnError(context);
      state.whenData((signInStatus) {
        if (signInStatus == true) {
          context.goNamed(AppRoute.home.name);
        }
      });
    });

    var state = ref.watch(loginControllerProvider);

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
                PasswordTextbox(
                  formFieldKey: _passwordKey,
                  passwordEditingController: _passwordEditingController,
                  state: state,
                  textInputAction: TextInputAction.done,
                  validator: (password) =>
                      passwordSignInErrorText(password, context),
                  onEditingComplete: _passwordEditingComplete,
                ),
                formSpacer,
                ElevatedButton(
                  onPressed:
                      state.isLoading ? null : () => _signIn(email, password),
                  child: state.isLoading
                      ? const CircularProgressIndicator()
                      : const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text("Login", style: TextStyle(fontSize: 20)),
                        ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: TextButton(
            onPressed: () => context.goNamed(AppRoute.emailPasswordReset.name),
            child:
                const Text("Forgot Password?", style: TextStyle(fontSize: 16)),
          ),
        ),
      ]),
    );
  }
}
