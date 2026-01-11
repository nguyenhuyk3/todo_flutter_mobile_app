// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:formz/formz.dart';

import '../../../core/constants/others.dart';

enum PasswordValidationError {
  empty,
  tooShort,
  missingUppercase,
  missingLowercase,
  missingNumber,
  missingSpecialChar,
}

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');
  const Password.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) {
      return PasswordValidationError.empty;
    }

    if (value.length < MINIMUM_LENGTH_FOR_PASSWORD) {
      return PasswordValidationError.tooShort;
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return PasswordValidationError.missingLowercase;
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return PasswordValidationError.missingUppercase;
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return PasswordValidationError.missingNumber;
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return PasswordValidationError.missingSpecialChar;
    }

    return null;
  }
}
