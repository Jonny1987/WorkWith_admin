import 'package:flutter/material.dart';

class TopSnackbar extends StatelessWidget {
  final Color color;
  final String text;
  const TopSnackbar({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
