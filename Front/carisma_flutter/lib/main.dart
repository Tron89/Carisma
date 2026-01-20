import 'package:carisma_flutter/start.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Carisma());
}

class Carisma extends StatefulWidget {
  const Carisma({super.key});

  @override
  State<Carisma> createState() => _CarismaState();
}

class _CarismaState extends State<Carisma> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Colors.red,
      home: Main(),
    );
  }
}