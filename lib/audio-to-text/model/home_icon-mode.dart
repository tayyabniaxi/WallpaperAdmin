// ignore_for_file: camel_case_types


import 'package:flutter/material.dart';

class Item {
  final String text;
  final String imageUrl;
   final List<Color> gradientColors;
  

  Item({required this.text, required this.imageUrl, required this.gradientColors});
}

class statusType {
  final String text;

  statusType({required this.text});
}
