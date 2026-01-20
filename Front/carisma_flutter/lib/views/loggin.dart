import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LogginView extends StatefulWidget {
  final VoidCallback onLogginSuccess;  
  const LogginView({super.key, required this.onLogginSuccess });

  @override
  State<LogginView> createState() => _LogginViewState();
}

class _LogginViewState extends State<LogginView> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: widget.onLogginSuccess,
          child: const Text('Log In'),
        ),
      ),
    );
  }
}