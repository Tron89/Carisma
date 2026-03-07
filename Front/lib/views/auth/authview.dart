import 'package:flutter/material.dart';
import 'package:carisma_flutter/views/auth/loggin.dart';

class Authview extends StatefulWidget {
  final void Function({
    required String token,
    required String tokenType,
    required Map<String, dynamic> user,
  }) onLogginSuccess;

  const Authview({super.key, required this.onLogginSuccess});

  @override
  State<Authview> createState() => _AuthviewState();
}

class _AuthviewState extends State<Authview> {
  late Widget currentView;

  void changeView({
    required Widget w
  }){
    setState(() {
      currentView = w;
    });
  }

  @override
  void initState() {
    super.initState();
    currentView = LogginView(onLogginSuccess: widget.onLogginSuccess, changeView: changeView);
  }

  @override
  Widget build(BuildContext context) {
    return currentView;
  }
}
