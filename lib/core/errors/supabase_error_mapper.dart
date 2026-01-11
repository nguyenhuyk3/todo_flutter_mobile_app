import 'package:supabase_flutter/supabase_flutter.dart';

import 'failure.dart';

ErrorInformation mapAuthException(AuthException e) {
  final message = e.message.toLowerCase();

  if (message.contains('should be different from the old password')) {
    return ErrorInformation.SAME_PASSWORD;
  }

  if (message.contains('invalid login credentials')) {
    return ErrorInformation.EMAIL_NOT_EXISTS;
  }

  if (message.contains('user already registered')) {
    return ErrorInformation.EMAIL_ALREADY_EXISTS;
  }

  if (message.contains('too many requests') || message.contains('rate limit')) {
    return ErrorInformation.OTP_TOO_MANY_REQUESTS;
  }

  if (message.contains('otp') && message.contains('invalid')) {
    return ErrorInformation.OTP_INVALID;
  }

  if (message.contains('invalid') || message.contains('token')) {
    return ErrorInformation.OTP_INVALID;
  }

  if (message.contains('expired')) {
    return ErrorInformation.OTP_EXPIRED;
  }

  return ErrorInformation.UNDEFINED_ERROR;
}

ErrorInformation mapPostgrestException(PostgrestException e) {
  switch (e.code) {
    case '23505':
      return ErrorInformation.EMAIL_ALREADY_EXISTS;

    case '23502':
      return ErrorInformation.DB_NOT_NULL_VIOLATION;

    case '23503':
      return ErrorInformation.DB_FOREIGN_KEY_VIOLATION;

    case '22P02':
      return ErrorInformation.DB_INVALID_FORMAT;

    case '42501':
      return ErrorInformation.DB_PERMISSION_DENIED;

    case 'PGRST116':
      return ErrorInformation.DB_RLS_VIOLATION;

    default:
      return ErrorInformation.UNDEFINED_ERROR;
  }
}
