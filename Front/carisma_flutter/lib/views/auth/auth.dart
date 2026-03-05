import 'package:carisma_flutter/views/auth/loggin.dart';
import 'package:carisma_flutter/views/auth/password.dart';
import 'package:carisma_flutter/views/auth/signin.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

import 'package:carisma_flutter/util/app_data.dart';
import 'package:carisma_flutter/util/http_connection.dart';

final Logger logger = Logger('LogginLogger');

class AuthenticationView extends StatefulWidget {
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

  const AuthenticationView({super.key, required this.onLogginSuccess});

  @override
  State<AuthenticationView> createState() => _AuthenticationViewState();
}

class _AuthenticationViewState extends State<AuthenticationView> {
  int menu = 0;
  void onMenuChange(int menu){
    setState(() {
      this.menu = menu;
    });
  }

  @override
  Widget build(BuildContext context) {
    return 
      menu == 0 ? LogginView(onLogginSuccess: widget.onLogginSuccess, changeMenu: onMenuChange,) : 
      menu == 1 ? SigninView(onLogginSuccess: widget.onLogginSuccess) : 
      ForgotPasswordView();
  }
}