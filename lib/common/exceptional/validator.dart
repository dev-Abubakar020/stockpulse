class CustomValidator {
  /// Validate required fields
  static String? validateEmptyText(String? fieldName, String? value) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }

    return null;
  }

  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required.';
    }

    final emailRegExp = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter.';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter.';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number.';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character.';
    }

    return null;
  }

  /// Validate Pakistani phone number
  /// Example: 03001234567
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required.';
    }

    final phoneRegExp = RegExp(r'^03\d{9}$');

    if (!phoneRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid phone number (e.g. 03001234567).';
    }

    return null;
  }
}