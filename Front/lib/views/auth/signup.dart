import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:carisma_flutter/util/http_connection.dart';
import 'package:carisma_flutter/util/functions.dart';

class LogginView extends StatefulWidget {
  final void Function({
    required String token,
    required Map<String, dynamic> user,
  })
  onLogginSuccess;

  const LogginView({super.key, required this.onLogginSuccess});

  @override
  State<LogginView> createState() => _LogginViewState();
}

class _LogginViewState extends State<LogginView> {
  final api = HttpConnection('http://10.0.2.2:8000/v1/');

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> onLoginPressed() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      showError(context, "Error", 'Inserte usuario y contraseña.');
      return;
    }

    final response = await api.post('login', {
      'username': emailController.text.trim(),
      'password': passwordController.text.trim(),
    });

    if (!mounted) return;

    if (response.statusCode != 200) {
      showError(context, "Error", 'Usuario o contraseña incorrectos.');
      return;
    }

    final data = jsonDecode(response.body);

    widget.onLogginSuccess(
      token: data["access_token"],
      user: data['user'] as Map<String, dynamic>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 235, 235, 235),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 50),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.black,
              width: 0.5
            ),
            color: Colors.white
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Username or Email'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ElevatedButton(
                    onPressed: onLoginPressed,
                    autofocus: true,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Color.fromARGB(255, 108, 213, 255),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Sign In'),
                  ),
                ),
                ElevatedButton(
                  onPressed: onLoginPressed,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.black, width: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Sign Up"),
                ),
                ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("Olvide la contraseña")
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
