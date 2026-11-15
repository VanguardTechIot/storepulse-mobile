import '../domain/email.dart';
import '../domain/password_policy.dart';
import '../domain/password_reset_code.dart';

class IamValidators {
  static const int fullNameMaxLength = 150;

  const IamValidators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu correo electrónico.';
    }
    if (!Email.isValid(value)) return 'Ingresa un correo electrónico válido.';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu contraseña.';
    if (value.length > PasswordPolicy.maximumLength) {
      return 'La contraseña no puede superar los '
          '${PasswordPolicy.maximumLength} caracteres.';
    }
    return null;
  }

  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa una contraseña.';
    if (!PasswordPolicy.isSatisfiedBy(value)) {
      return 'La contraseña no cumple los requisitos.';
    }
    return null;
  }

  static String? Function(String?) confirmation(String Function() original) =>
      (value) {
        if (value == null || value.isEmpty) return 'Confirma la contraseña.';
        if (value != original()) return 'Las contraseñas no coinciden.';
        return null;
      };

  static String? fullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu nombre completo.';
    }
    if (value.trim().length > fullNameMaxLength) {
      return 'El nombre no puede superar los $fullNameMaxLength caracteres.';
    }
    return null;
  }

  static String? resetCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa el código que recibiste.';
    }
    if (!PasswordResetCode.isValid(value)) {
      return 'El código tiene ${PasswordResetCode.length} dígitos.';
    }
    return null;
  }
}
