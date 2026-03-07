import 'package:flutter/material.dart';

enum AppColors {
  primary(Color.fromARGB(255, 0, 188, 255)),
  secondary(Color.fromARGB(255, 255, 255, 255)),
  selected(Color.fromARGB(255, 0, 188, 255)),
  unselected(Color.fromARGB(255, 147, 147, 147)),
  buttonPrimary(Color.fromARGB(255, 22, 87, 110)),
  buttonSecondary(Color.fromARGB(255, 125, 222, 255)),
  background(Colors.white);

  final Color color;
  const AppColors(this.color);
}