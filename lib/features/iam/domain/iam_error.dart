enum IamErrorCode {
  invalidCredentials('invalid_credentials'),
  accountInactive('account_inactive'),
  emailAlreadyRegistered('email_already_registered'),
  weakPassword('weak_password'),
  invalidResetCode('invalid_reset_code'),
  expiredResetCode('expired_reset_code'),
  userNotFound('user_not_found'),
  unauthorized('unauthorized'),
  unreachable('unreachable'),
  unexpected('unexpected');

  final String value;

  const IamErrorCode(this.value);

  static IamErrorCode fromValue(String? value) =>
      IamErrorCode.values.firstWhere(
        (code) => code.value == value,
        orElse: () => IamErrorCode.unexpected,
      );
}

class IamError implements Exception {
  final IamErrorCode code;

  const IamError(this.code);

  @override
  String toString() => 'IamError(${code.value})';
}
