import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workwith_admin/utils/constants.dart';

extension AsyncValueUI on AsyncValue {
  void showTopSnackbarOnError(BuildContext context) {
    if (!isLoading && hasError) {
      context.showError(context, error, StackTrace.current);
    }
  }
}
