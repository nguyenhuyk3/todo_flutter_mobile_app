// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:formz/formz.dart';

enum OtpValidationError { empty, incorrectSixDigits, noTextAllowed }

class Otp extends FormzInput<String, OtpValidationError> {
  const Otp.pure() : super.pure('');
  const Otp.dirty([super.value = '']) : super.dirty();

  @override
  OtpValidationError? validator(String value) {
    if (value.isEmpty) {
      return OtpValidationError.empty;
    }

    if (RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return OtpValidationError.noTextAllowed;
    }

    if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
      return OtpValidationError.incorrectSixDigits;
    }

    return null;
  }
}
