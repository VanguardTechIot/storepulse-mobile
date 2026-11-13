class PasswordPolicyEvaluation {
  final bool hasMinimumLength;
  final bool hasNumber;
  final bool withinMaximumLength;

  const PasswordPolicyEvaluation({
    required this.hasMinimumLength,
    required this.hasNumber,
    required this.withinMaximumLength,
  });

  bool get isSatisfied => hasMinimumLength && hasNumber && withinMaximumLength;
}

class PasswordPolicy {
  static const int minimumLength = 8;
  static const int maximumLength = 72;

  static final RegExp _number = RegExp(r'\d');

  const PasswordPolicy._();

  static PasswordPolicyEvaluation evaluate(String password) =>
      PasswordPolicyEvaluation(
        hasMinimumLength: password.length >= minimumLength,
        hasNumber: _number.hasMatch(password),
        withinMaximumLength: password.length <= maximumLength,
      );

  static bool isSatisfiedBy(String password) => evaluate(password).isSatisfied;
}
