import 'dart:io';

import 'package:carisma_flutter/util/Errors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class Functions {
  static void showError(BuildContext context, String title, String message,
      {String? error}){
    stderr.writeln(error);
    showDialog(
      context: context,
      builder: (context) {
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
      },
    );
  }

  static String getError(Response response){
    return switch (response.statusCode) {
      400 => ErrorType.E400.message,
      401 => ErrorType.E401.message,
      403 => ErrorType.E403.message,
      404 => ErrorType.E404.message,
      409 => ErrorType.E409.message,
      422 => ErrorType.E422.message,
      500 => ErrorType.E500.message,
      _ => 'Error inesperado [${response.statusCode}](${response.body})'
    };
  }
}