import 'package:flutter/material.dart';

class AddVenueButton extends StatelessWidget {
  final void Function() onPress;
  const AddVenueButton({Key? key, required this.onPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        )),
      ),
      onPressed: onPress,
      child: const Padding(
        padding: EdgeInsets.all(10.0),
        child: Text('Add Venue', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
