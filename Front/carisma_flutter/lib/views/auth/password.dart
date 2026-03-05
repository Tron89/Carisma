import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

import 'package:carisma_flutter/util/app_data.dart';
import 'package:carisma_flutter/util/http_connection.dart';

final Logger logger = Logger('LogginLogger');

class ForgotPasswordView extends StatefulWidget {
  void startLogger(){
    Logger.root.level = Level.ALL; // Set the logging level
    Logger.root.onRecord.listen((record) {
      // Customize the log output format
      print('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    });
  }

  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("FORGOT PASSWORD"),
    );
  }
}