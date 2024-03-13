import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/features/auth/presentation/string_validators.dart';

class PasswordTextbox extends StatelessWidget {
  final GlobalKey formFieldKey;
  final TextEditingController passwordEditingController;
  final AsyncValue state;
  final TextInputAction textInputAction;
  final Function validator;
  final Function onEditingComplete;
  const PasswordTextbox({
    super.key,
    required this.formFieldKey,
    required this.passwordEditingController,
    required this.state,
    required this.textInputAction,
    required this.validator,
    required this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: formFieldKey,
      controller: passwordEditingController,
      enabled: !state.isLoading,
      obscureText: true,
      decoration: const InputDecoration(
        label: Text('Password'),
      ),
      textInputAction: textInputAction,
      autocorrect: false,
      // autovalidateMode: AutovalidateMode.onUserInteraction,
      onEditingComplete: () => onEditingComplete(),
      validator: (password) => validator(password ?? ''),
      inputFormatters: <TextInputFormatter>[
        ValidatorInputFormatter(
            editingValidator: PasswordEditingRegexValidator()),
      ],
    );
  }
}
