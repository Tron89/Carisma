import 'package:flutter/material.dart';
import 'package:carisma_flutter/views/loggin.dart';
import 'package:carisma_flutter/views/home.dart';

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  bool isLoggedIn = false;

  void logginSuccess(){
    setState(() {
      isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn ? const HomeView() : LogginView(onLogginSuccess: logginSuccess);
  }
}