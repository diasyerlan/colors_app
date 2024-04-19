import 'package:flutter/material.dart';

void displayMessage(String text, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(text),
        );
      });
}

Color getColorFromString(String colorString) {
  if (colorString.startsWith('Color(')) {
    String valueString = colorString.split('(0x')[1].split(')')[0];
    int value = int.tryParse(valueString, radix: 16) ?? 0xFF000000;

    return Color(value);
  } else {
    return Colors.transparent;
  }
}
