/// Form field checks. Each returns the message to show, or null when valid.
abstract final class Validators {
  static String? name(String name) {
    if (name.trim().isEmpty) {
      return 'Enter a name';
    } else if (name.length > 100) {
      return 'Use at most 100 characters';
    }
    return null;
  }

  /// E.164, e.g. +2348012345678. Empty is allowed when [optional].
  static String? phone(String phone, {bool optional = false}) {
    final RegExp regex = RegExp(r"^\+[1-9]\d{6,14}$");

    if (phone.isEmpty) {
      return optional ? null : 'Enter a phone number';
    } else if (!regex.hasMatch(phone)) {
      return 'Use the international format, e.g. +2348012345678';
    }
    return null;
  }

  static String? email(String email) {
    final RegExp regex = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");

    if (email.isEmpty) {
      return 'Enter an email';
    } else if (!regex.hasMatch(email.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  /// For sign-in: the account's existing password may predate the 12-character rule.
  static String? required(String value, {String field = 'this field'}) {
    if (value.isEmpty) {
      return 'Enter $field';
    }
    return null;
  }

  /// For a new password: 12 to 128 characters.
  static String? password(String password) {
    if (password.isEmpty) {
      return 'Enter a password.';
    } else if (password.length < 12) {
      return 'Use at least 12 characters.';
    } else if (password.length > 128) {
      return 'Use at most 128 characters.';
    }
    return null;
  }

  static String? confirmPassword(
    String? newPassword, {
    required String oldPassword,
  }) {
    if (newPassword == null || newPassword.isEmpty) {
      return 'required';
    } else if (newPassword != oldPassword) {
      return 'The passwords are not the same.';
    }
    return null;
  }
}
