import '../domain/email_address.dart';
import '../domain/phone_number.dart';
import '../domain/profile.dart';
import '../domain/profile_photo.dart';

class ProfilesValidators {
  const ProfilesValidators._();

  static String? firstName(String? value) => _name(value, 'tu nombre');

  static String? lastName(String? value) => _name(value, 'tu apellido');

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu correo electrónico.';
    }
    if (!EmailAddress.isValid(value)) {
      return 'Ingresa un correo electrónico válido.';
    }
    return null;
  }

  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!PhoneNumber.isValid(value)) {
      return 'Usa de ${PhoneNumber.minDigits} a ${PhoneNumber.maxDigits} '
          'dígitos; se permiten +, espacios, guiones y paréntesis.';
    }
    return null;
  }

  static String? photoUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el enlace de la imagen.';
    }
    if (!ProfilePhoto.isValid(value)) {
      return 'Usa un enlace http(s) que termine en .jpg, .jpeg o .png.';
    }
    return null;
  }

  static String? _name(String? value, String field) {
    if (value == null || value.trim().isEmpty) return 'Ingresa $field.';
    if (!Profile.isValidName(value)) {
      return 'Máximo ${Profile.nameMaxLength} caracteres.';
    }
    return null;
  }
}
