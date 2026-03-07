import 'dart:convert';

import 'package:carisma_flutter/util/colors.dart';
import 'package:carisma_flutter/util/commons.dart';
import 'package:carisma_flutter/views/auth/authService.dart';
import 'package:carisma_flutter/views/auth/loggin.dart';
import 'package:flutter/material.dart';
import 'package:carisma_flutter/util/http_connection.dart';
import 'package:carisma_flutter/util/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpView extends StatefulWidget {
  final void Function({
    required String token,
    required String tokenType,
    required Map<String, dynamic> user,
  }) onLogginSuccess;

  final void Function({
    required Widget w
  }) changeView;

  const SignUpView({super.key, required this.onLogginSuccess, required this.changeView});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final authService = Authservice(HttpConnection(urlString));

  final userController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    userController.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  Future<void> onSignUpPressed() async {
    if (userController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      Functions.showError(context, "Error", 'Inserte usuario, correo y contraseña.');
      return;
    }

    final response = await authService.registerAndLogin(
        userController.text.trim(),
        emailController.text,
        passwordController.text.trim()
    );
    if (!mounted) return;

    if (response.statusCode != 201) {
      Functions.showError(context, "Error", Functions.getError(response), error: response.body);
      return;
    }

    final data = jsonDecode(response.body);

    widget.onLogginSuccess(
      token: data['access_token'],
      tokenType: data['token_type'],
      user: data['user'] as Map<String, dynamic>,
    );

    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', data["access_token"]);
    prefs.setString('token_type', data["token_type"]);
    prefs.setString('user', jsonEncode(data['user']));
  }

  void onLoginPressed(){
    widget.changeView(w: LogginView(onLogginSuccess: widget.onLogginSuccess, changeView: widget.changeView));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 235, 235, 235),
      body: Center(
        child: IntrinsicWidth(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 275
            ),
            child: Container(
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
                      "Crear cuenta",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    TextField(
                      controller: userController,
                      decoration: InputDecoration(labelText: 'Usuario'),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: 'Contraseña'),
                      obscureText: true,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 5),
                      child: ElevatedButton(
                        onPressed: onSignUpPressed,
                        autofocus: true,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          overlayColor: Color.fromARGB(25, 0, 0, 0),
                          backgroundColor: AppColors.buttonSecondary.color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Crear cuenta'),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onLoginPressed,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        overlayColor: Color.fromARGB(25, 0, 0, 0),
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.black, width: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Iniciar sesion"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
