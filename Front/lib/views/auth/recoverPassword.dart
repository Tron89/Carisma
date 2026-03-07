import 'package:carisma_flutter/util/colors.dart';
import 'package:carisma_flutter/util/commons.dart';
import 'package:carisma_flutter/views/auth/authService.dart';
import 'package:carisma_flutter/views/auth/loggin.dart';
import 'package:flutter/material.dart';
import 'package:carisma_flutter/util/http_connection.dart';

class RecoverPasswordView extends StatefulWidget {
  final void Function({
    required String token,
    required String tokenType,
    required Map<String, dynamic> user,
  }) onLogginSuccess;

  final void Function({
    required Widget w
  }) changeView;

  const RecoverPasswordView({super.key, required this.onLogginSuccess, required this.changeView});

  @override
  State<RecoverPasswordView> createState() => _RecoverPasswordViewState();
}

class _RecoverPasswordViewState extends State<RecoverPasswordView> {
  final authService = Authservice(HttpConnection(urlString));

  final emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
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
                      "Recuperar contraseña",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Usuario o Email'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 5),
                      child: ElevatedButton(
                        onPressed: null,
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
                        child: const Text('Enviar'),
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
