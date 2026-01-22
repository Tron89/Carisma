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

  late String token;
  late Map<String, dynamic> user;

  void logginSuccess({
    required String token,
    required Map<String, dynamic> user,
  }){
    setState(() {
      this.token = token;
      this.user = user;
      isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn ? HomeView(token: token, user: user) : LogginView(onLogginSuccess: logginSuccess);
  }
}