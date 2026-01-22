import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:carisma_flutter/util/http_connection.dart';

class LogginView extends StatefulWidget {
  final void Function({
    required String token,
    required Map<String, dynamic> user,
  }) onLogginSuccess;

  const LogginView({super.key, required this.onLogginSuccess });

  @override
  State<LogginView> createState() => _LogginViewState();
}

class _LogginViewState extends State<LogginView> {
  final api = HttpConnection('http://10.0.2.2:8000/v1/');

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> onLoginPressed() async {
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: const Text('Please enter both username and password.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      });
      return;
    }

    final response = await api.post('login', {
      'username': emailController.text.trim(),
      'password': passwordController.text.trim(),
    });

    if (response.statusCode != 200) {
      showDialog(context: context, builder: (context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: const Text('Invalid username or password.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      });
      return;
    }

    final data = jsonDecode(response.body);

    widget.onLogginSuccess(token: data["access_token"], user: data['user'] as Map<String, dynamic>);
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
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  onPressed: onLoginPressed,
                  autofocus: true,
                  child: const Text('Log In'),
                ),
              ),
              ElevatedButton(
                onPressed: onLoginPressed,
                child: const Text("Don't have an account? Sign Up"),
              ),
            ],
          )
        ),
      ),
    );
  }
}