// ignore_for_file: camel_case_types, must_be_immutable, use_key_in_widget_constructors

import 'package:flutter/material.dart';

class height extends StatelessWidget {
  double size;
  height({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * size,
    );
  }
}
