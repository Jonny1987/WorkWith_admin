import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workwith_admin/utils/top_snack_bar.dart';

/// Supabase client
final supabase = Supabase.instance.client;

/// Simple preloader inside a Center widget
const preloader =
    Center(child: CircularProgressIndicator(color: Colors.orange));

/// Simple sized box to space out form elements
const formSpacer = SizedBox(width: 16, height: 16);

/// Some padding for all the forms to use
const formPadding = EdgeInsets.symmetric(vertical: 20, horizontal: 16);

/// Error message to display the user when unexpected error occurs.
const unexpectedErrorMessage = 'Unexpected error occurred.';

/// Basic theme to change the look and feel of the app
final appTheme = ThemeData.light().copyWith(
  primaryColorDark: Colors.orange,
  appBarTheme: const AppBarTheme(
    elevation: 1,
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 18,
    ),
  ),
  primaryColor: Colors.orange,
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.orange,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.orange,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    floatingLabelStyle: const TextStyle(
      color: Colors.orange,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.grey,
        width: 2,
      ),
    ),
    focusColor: Colors.orange,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Colors.orange,
        width: 2,
      ),
    ),
  ),
);

class TransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TransparentAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(
      kToolbarHeight); // This is the default AppBar height
}

void showTopSnackBar(BuildContext context, String text, Color color) {
  OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => SafeArea(
      child: IgnorePointer(
        child: Material(
          color: Colors.transparent,
          child: Column(
            // Wrap your TopSnackBar inside a Column
            mainAxisSize: MainAxisSize.min, // Use as little space as needed
            children: <Widget>[
              TopSnackbar(
                  color: color, text: text), // Use the created TopSnackBar
            ],
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(overlayEntry);

  // The overlay will be displayed for 3 seconds
  Future.delayed(const Duration(seconds: 5), () {
    overlayEntry.remove();
  });
}

Color errorColor = Colors.red;
Color successColor = Colors.green;

/// Set of extension methods to easily display a snackbar
extension ShowSnackBar on BuildContext {
  void showError(
      BuildContext context, dynamic exception, StackTrace stackTrace) {
    debugPrint("$exception,\n$stackTrace");
    showTopSnackBar(
      context,
      exception.toString(),
      errorColor,
    );
  }

  void showSuccessMessage(BuildContext context, String message) {
    debugPrint(message);
    showTopSnackBar(
      context,
      message,
      successColor,
    );
  }
}
