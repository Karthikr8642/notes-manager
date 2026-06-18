class Validators {
  static String? validateName(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  static String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Email is required';
    }

    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(v)) {
      return 'Enter a valid email';
    }

    return null;
  }

  static String? validatePassword(String? v) {
    if (v == null || v.isEmpty) {
      return 'Password is required';
    }

    if (v.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  static String? validateConfirm(String? a, String? b) {
    if (b == null || b.isEmpty) {
      return 'Please confirm password';
    }

    if (a != b) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? validateTitle(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Title is required';
    }
    return null;
  }
}