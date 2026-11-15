import '../domain/iam_error.dart';

extension IamErrorMessage on IamErrorCode {
  String get message => switch (this) {
    IamErrorCode.invalidCredentials => 'Correo o contraseña incorrectos.',
    IamErrorCode.accountInactive =>
      'Tu cuenta está inactiva. Comunícate con el administrador de tu galería.',
    IamErrorCode.emailAlreadyRegistered =>
      'Ese correo ya está registrado en StorePulse.',
    IamErrorCode.weakPassword =>
      'La contraseña debe tener al menos 8 caracteres y un número.',
    IamErrorCode.invalidResetCode =>
      'El código no es válido. Revisa el correo que te enviamos.',
    IamErrorCode.expiredResetCode =>
      'El código venció. Solicita uno nuevo para continuar.',
    IamErrorCode.userNotFound => 'No encontramos tu cuenta.',
    IamErrorCode.unauthorized => 'Tu sesión venció. Inicia sesión nuevamente.',
    IamErrorCode.unreachable =>
      'No se pudo conectar con StorePulse. Revisa tu conexión.',
    IamErrorCode.unexpected =>
      'Ocurrió un error inesperado. Inténtalo nuevamente.',
  };
}
