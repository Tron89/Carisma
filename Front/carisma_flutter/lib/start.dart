import 'package:carisma_flutter/views/auth/auth.dart';
import 'package:logging/logging.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:carisma_flutter/util/app_data.dart';
import 'package:carisma_flutter/views/auth/loggin.dart';
import 'package:carisma_flutter/views/home.dart';
import 'package:carisma_flutter/util/http_connection.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Logger logger = Logger('MainLogger');

class Start extends StatefulWidget {
  const Start({super.key});

  void startLogger(){
    Logger.root.level = Level.ALL; // Set the logging level
    Logger.root.onRecord.listen((record) {
      // Customize the log output format
      print('${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
    });
  }

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  final api = HttpConnection(AppData.SERVER_URL);
  late SharedPreferences prefs;

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    logger.config("SharedPreferences initialized");
  }

  bool isLoggedIn = false;
  bool haveAnAcount = true;

  late String token;
  late Map<String, dynamic> user;

  void openLoggingView(){
    setState(() {
      haveAnAcount = true;
    });
  }

  void openSigningView(){
    setState(() {
      haveAnAcount = false;
    });
  }

  void logginSuccess({
    required String token,
    required Map<String, dynamic> user,
  }){
    setState(() {
      this.token = token;
      this.user = user;
      isLoggedIn = true;
    });
  }

  void onLogout(){
    setState(() {
      isLoggedIn = false;
      prefs.setString('access_token', '');
      prefs.setString('token_type', '');
      prefs.setString('user', '');
    });
  }

  Future<void> checkLoginStatus() async {
    final storedToken = prefs.getString('access_token');
    final storedTokenType = prefs.getString('token_type');
    final storedUser = prefs.getString('user');

    if (storedToken != null && storedUser != null) {
      final result = await api.get(
        'users/me', 
        headers: {
          'Authorization': '$storedTokenType $storedToken',
        }
      );

      logger.config("Token verification response code: ${result.statusCode}");
      logger.config("Server message: ${result.body}");

      // Si la verificación falla, no iniciar sesión automáticamente
      if (result.statusCode != AppData.OK_CODE) return;
      
      setState(() {
        token = storedToken;
        user = jsonDecode(storedUser) as Map<String, dynamic>;
        isLoggedIn = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initPrefs().then((_) {
      checkLoginStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoggedIn ? HomeView(token: token, user: user, onLogout: onLogout,) : AuthenticationView(onLogginSuccess: logginSuccess);
  }
}