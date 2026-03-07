import 'dart:convert';

import 'package:carisma_flutter/views/auth/authview.dart';
import 'package:flutter/material.dart';
import 'package:carisma_flutter/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  bool isLoggedIn = false;

  late String token;
  late String tokenType;
  late Map<String, dynamic> user;

  Future<void> tryLogin() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.containsKey('token') && prefs.containsKey('token_type') && prefs.containsKey('user');
    if (!isLoggedIn) return;

    token = prefs.getString('token')!;
    tokenType = prefs.getString('token_type')!;
    user = jsonDecode(prefs.getString('user')!);
  }

  @override
  void initState() {
    super.initState();
    tryLogin();
  }

  void loginSuccess({
    required String token,
    required String tokenType,
    required Map<String, dynamic> user,
  }){
    setState(() {
      this.token = token;
      this.tokenType = tokenType;
      this.user = user;
      isLoggedIn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn ? HomeView(token: token, user: user) : Authview(onLogginSuccess: loginSuccess);
  }
}