import 'package:flutter/material.dart';

class Functions {
  static void showErrorDialog(BuildContext context, String title, String message){
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    });
  }
}