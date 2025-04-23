
// ignore_for_file: use_key_in_widget_constructors, must_be_immutable

import 'package:flutter/material.dart';

class CommonText extends StatelessWidget {
  String title;
  Color color;
  double size;
  FontWeight? fontWeight;
  CommonText(
      {required this.title,
      required this.color,
      required this.size,
      this.fontWeight});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
          color: color,
          fontSize: MediaQuery.of(context).size.height * size,
          fontWeight: fontWeight),
    );
  }
}
