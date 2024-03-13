import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/src/features/auth/presentation/email_password_validators.dart';
import 'package:workwith_admin/src/features/auth/presentation/string_validators.dart';

class EmailTextbox extends StatelessWidget {
  final GlobalKey formFieldKey;
  final TextEditingController emailEditingController;
  final AsyncValue state;
  final TextInputAction textInputAction;
  final Function onEditingComplete;
  const EmailTextbox({
    super.key,
    required this.formFieldKey,
    required this.emailEditingController,
    required this.state,
    required this.textInputAction,
    required this.onEditingComplete,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: formFieldKey,
      controller: emailEditingController,
      enabled: !state.isLoading,
      decoration: const InputDecoration(
        label: Text('Email'),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      autocorrect: false,
      // autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (email) => emailErrorText(email ?? '', context),
      onEditingComplete: () => onEditingComplete(),
      inputFormatters: <TextInputFormatter>[
        ValidatorInputFormatter(editingValidator: EmailEditingRegexValidator()),
      ],
    );
  }
}
