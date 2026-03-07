

import 'package:carisma_flutter/util/functions.dart';
import 'package:carisma_flutter/util/http_connection.dart';
import 'package:http/http.dart';

class Authservice {
  final HttpConnection api;
  Authservice(this.api);

  Future<Response> login(String email, String password) async {
    final response = await api.post('login', {
      'user': email,
      'password': password,
    });

    Functions.showDebug(response.body, tag: 'login');

    return response;
  }

  Future<Response> register(String username, String email, String password) async {
    final response = await api.post('register', {
      'username': username,
      'email': email,
      'password': password,
    });

    Functions.showDebug(response.body, tag: 'register');

    return response;
  }

  Future<Response> registerAndLogin(String username, String email, String password) async {
    final registered = await register(username, email, password);
    if (registered.statusCode != 201) return registered;
    return await login(email, password);
  }
}