import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

import 'package:carisma_flutter/util/app_data.dart';
import 'package:carisma_flutter/util/http_connection.dart';

final Logger logger = Logger('LogginLogger');

class SigninView extends StatefulWidget {
  void startLogger(){
    Logger.root.level = Level.ALL; // Set the logging level
    Logger.root.onRecord.listen((record) {
      // Customize the log output format
      print('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    });
  }

  final void Function({
    required String token,
    required Map<String, dynamic> user,
  }) onLogginSuccess;

  
  const SigninView({super.key, required this.onLogginSuccess});

  @override
  State<SigninView> createState() => _SigninViewState();
}

class _SigninViewState extends State<SigninView> {
  final api = HttpConnection(AppData.SERVER_URL);
  late SharedPreferences prefs;
  
  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }
  
  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Username or Email',
                ),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
              ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 20.0),
              //   child: ElevatedButton(
              //     onPressed: onLoginPressed,
              //     autofocus: true,
              //     child: const Text('Sign in'),
              //   ),
              // ),
              // ElevatedButton(
              //   onPressed: onNewAcount,
              //   child: const Text("Already have an account? Log in"),
              // ),
              // ElevatedButton(
              //   onPressed: onForgotPassword,
              //   child: const Text("I have forgoten my password"),
              // ),
            ],
          )
        ),
      ),
    );
  }
}