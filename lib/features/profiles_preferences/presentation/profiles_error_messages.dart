import '../domain/profiles_error.dart';

extension ProfilesErrorMessage on ProfilesErrorCode {
  String get message => switch (this) {
    ProfilesErrorCode.invalidName =>
      'El nombre y el apellido son obligatorios (máximo 50 caracteres).',
    ProfilesErrorCode.invalidEmail => 'Ingresa un correo electrónico válido.',
    ProfilesErrorCode.invalidPhoneNumber =>
      'Ingresa un teléfono válido de 7 a 15 dígitos.',
    ProfilesErrorCode.unsupportedPhotoFormat =>
      'La foto debe ser un enlace http(s) a una imagen JPG o PNG.',
    ProfilesErrorCode.emailAlreadyRegistered =>
      'Ese correo ya pertenece a otra cuenta de StorePulse.',
    ProfilesErrorCode.profileNotFound => 'No encontramos tu perfil.',
    ProfilesErrorCode.accessDenied =>
      'Tu sesión venció. Inicia sesión nuevamente.',
    ProfilesErrorCode.unreachable =>
      'No se pudo conectar con StorePulse. Revisa tu conexión.',
    ProfilesErrorCode.unexpected =>
      'Ocurrió un error inesperado. Inténtalo nuevamente.',
  };
}
