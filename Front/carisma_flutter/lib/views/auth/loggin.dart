import 'package:carisma_flutter/util/functions.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

import 'package:carisma_flutter/util/app_data.dart';
import 'package:carisma_flutter/util/http_connection.dart';

final Logger logger = Logger('LogginLogger');

class LogginView extends StatefulWidget {
  // Iniciar el logger
  void startLogger(){
    Logger.root.level = Level.ALL; // Set the logging level
    Logger.root.onRecord.listen((record) {
      // Customize the log output format
      print('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    });
  }

  // Funciones
  final void Function({
    required String token,
    required Map<String, dynamic> user,
  }) onLogginSuccess;

  final void Function(int menu) changeMenu;

  // Constructor
  const LogginView({super.key, required this.onLogginSuccess, required this.changeMenu});

  @override
  State<LogginView> createState() => _LogginViewState();
}

class _LogginViewState extends State<LogginView> {
  // Iniciamos cosas
  final api = HttpConnection(AppData.SERVER_URL);
  late SharedPreferences prefs;
  
  // Funcion para cargar archivo de preferencias
  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }
  
  // El initState que se ejecuta al iniciar esta clase
  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  // Creamos controllers para email/usuario y contraseña
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // No se que hace
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }


  // Parte que hace toda la comprobacion del login
  Future<void> onLoginPressed() async {
    // Revisa que los campos de texto no esten vacios
    if (emailController.text.trim().isEmpty || passwordController.text.trim().isEmpty) {
      Functions.showErrorDialog(context, 'Error', 'Please enter both username and password.');
      return;
    }

    // Pedimos al servidor que revise si esta todo bien
    final response = await api.post('login', {
      'user': emailController.text.trim(),
      'password': passwordController.text.trim(),
    });

    // Loggers
    logger.info("Response status code: ${response.statusCode}");
    logger.info("Response body: ${response.body}");

    // Si algun campo esta mal, error
    if (response.statusCode != AppData.OK_CODE) {
      Functions.showErrorDialog(context, 'Login Failed', 'Invalid username or password.');
      return;
    }

    // Extraemos la info que nos ha dado el server
    final data = jsonDecode(response.body);

    // Agregamos o actualizamos nuestra info en las preferencias
    await prefs.setString('access_token', data['access_token']);
    await prefs.setString('token_type', data['token_type']);
    await prefs.setString('user', jsonEncode(data['user']));
    
    // Le decimos al authView que todo salio bien y le damos los datos :)
    widget.onLogginSuccess(token: data["access_token"], user: data['user'] as Map<String, dynamic>);
  }

  // Funcion que le dice al authView que cambie la vista a crear cuenta
  void onNewAcount(){
    widget.changeMenu(1);
  }

  // Funcion que le dice al authView que cambie la vista a no se mi contraseña
  void onForgotPassword(){
    widget.changeMenu(2);
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
                onPressed: onNewAcount,
                child: const Text("Don't have an account? Sign Up"),
              ),
              ElevatedButton(
                onPressed: onForgotPassword,
                child: const Text("I have forgoten my password"),
              ),
            ],
          )
        ),
      ),
    );
  }
}