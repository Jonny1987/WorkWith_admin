import 'package:flutter/material.dart';

class ImageButton extends StatelessWidget {
  final Function() onPressed;
  final String? text;
  final IconData? icon;
  const ImageButton({Key? key, required this.onPressed, this.text, this.icon})
      : super(key: key);

  Widget getChild() {
    if (text != null) {
      return Text(
        text!,
        style: const TextStyle(
          fontSize: 22,
          color: Colors.black,
        ),
      );
    } else if (icon != null) {
      return Icon(
        icon,
        color: Colors.black,
      );
    } else {
      throw Exception('No text or icon provided');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          elevation: 5,
          backgroundColor: Colors.white,
          foregroundColor: Colors.orange,
          fixedSize: const Size(50, 50),
        ),
        onPressed: onPressed,
        child: getChild(),
      ),
    );
  }
}
