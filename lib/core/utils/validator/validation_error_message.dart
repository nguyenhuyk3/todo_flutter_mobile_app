
import '../../../features/authentication/inputs/email.dart';
import '../../../features/authentication/inputs/otp.dart';
import '../../../features/authentication/inputs/password.dart';
import '../../constants/others.dart';
import '../../errors/failure.dart';

class ValidationErrorMessage {
  static String? getEmailErrorMessage({EmailValidationError? error}) {
    switch (error) {
      case EmailValidationError.empty:
        return ErrorInformation.EMAIL_CAN_NOT_BE_BLANK.message;
      case EmailValidationError.invalid:
        return ErrorInformation.INVALID_EMAIL.message;
      default:
        return null;
    }
  }

  static String? getPasswordErrorMessage({
    required PasswordValidationError? error,
  }) {
    switch (error) {
      case PasswordValidationError.empty:
        return ErrorInformation.EMPTY_PASSWORD.message;
      case PasswordValidationError.tooShort:
        return ErrorInformation.PASSWORD_TOO_SHORT.message;
      case PasswordValidationError.missingLowercase:
        return ErrorInformation.PASSWORD_MISSING_LOWERCASE.message;
      case PasswordValidationError.missingUppercase:
        return ErrorInformation.PASSWORD_MISSING_UPPERCASE.message;
      case PasswordValidationError.missingNumber:
        return ErrorInformation.PASSWORD_MISSING_NUMBER.message;
      case PasswordValidationError.missingSpecialChar:
        return ErrorInformation.PASSWORD_MISSING_SPECIAL_CHAR.message;
      default:
        return null;
    }
  }

  static String? getOtpErrorMessage({OtpValidationError? error}) {
    switch (error) {
      case OtpValidationError.empty:
        return "Otp không được để trống";
      case OtpValidationError.incorrectSixDigits:
        return "Mã Otp phải có đúng $LENGTH_OF_OTP kí tự";
      case OtpValidationError.noTextAllowed:
        return "Mã otp không được có chữ cái";
      default:
        return null;
    }
  }
}
