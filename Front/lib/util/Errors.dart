enum ErrorType {
  E400(400, 'Solicitud incorrecta.'),
  E401(401, 'Usuario o contraseña incorrectos.'),
  E403(403, 'No tienes permiso para realizar esta acción.'),
  E404(404, 'No encontrado.'),
  E409(409, 'El usuario ya existe.'),
  E422(422, 'Los datos enviados no son válidos.'),
  E500(500, 'Error interno del servidor.');

  final int code;
  final String message;
  const ErrorType(this.code, this.message);
}