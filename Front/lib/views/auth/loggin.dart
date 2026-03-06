import 'dart:convert';

import 'package:carisma_flutter/util/Errors.dart';
import 'package:carisma_flutter/views/auth/AuthService.dart';
import 'package:carisma_flutter/views/auth/recoverPassword.dart';
import 'package:carisma_flutter/views/auth/signup.dart';
import 'package:flutter/material.dart';
import 'package:carisma_flutter/util/http_connection.dart';
import 'package:carisma_flutter/util/functions.dart';
import 'package:carisma_flutter/util/commons.dart';

class LogginView extends StatefulWidget {
  final void Function({
    required String token,
    required Map<String, dynamic> user,
  }) onLogginSuccess;

  final void Function({
    required Widget w
  }) changeView;

  const LogginView({super.key, required this.onLogginSuccess, required this.changeView});

  @override
  State<LogginView> createState() => _LogginViewState();
}

class _LogginViewState extends State<LogginView> {
  final authService = Authservice(HttpConnection(urlString));

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  Future<void> onLoginPressed() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      Functions.showError(context, "Error", 'Inserte usuario y contraseña.');
      return;
    }

    final response = await authService.login(
        emailController.text.trim(),
        passwordController.text.trim()
    );
    if (!mounted) return;

    if (response.statusCode != 200) {
      Functions.showError(context, "Error", Functions.getError(response), error: response.body);
      return;
    }

    final data = jsonDecode(response.body);

    widget.onLogginSuccess(
      token: data["access_token"],
      user: data['user'] as Map<String, dynamic>,
    );
  }

  void onRecoveryPressed(){
    widget.changeView(w: RecoverPasswordView(onLogginSuccess: widget.onLogginSuccess, changeView: widget.changeView));
  }

  void onSignUpPressed(){
    widget.changeView(w: SignUpView(onLogginSuccess: widget.onLogginSuccess, changeView: widget.changeView));
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
                Text(
                  "Iniciar sesion",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Usuario o Email'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Contraseña'),
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
                    child: const Text('Iniciar sesion'),
                  ),
                ),
                ElevatedButton(
                  onPressed: onSignUpPressed,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.black, width: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Crear cuenta"),
                ),
                ElevatedButton(
                  onPressed: onRecoveryPressed,
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
