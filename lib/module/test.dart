import 'package:flutter/material.dart';

colortest(Color _color, String colorName) {
  return Text(
    'this color is $colorName',
    style: TextStyle(backgroundColor: _color),
  );
}
