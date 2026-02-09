import 'package:formz/formz.dart';

enum EmailValidationError { empty, invalid }

// FormzInput<Value, Error>
class Email extends FormzInput<String, EmailValidationError> {
  // Constructors
  // "pure" means nothing has entered (the initial state).
  const Email.pure() : super.pure('');
  // "dirty" refers to what the user has entered (whether correct or incorrect).
  const Email.dirty([super.value = '']) : super.dirty();

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  EmailValidationError? validator(String value) {
    if (value.isEmpty) {
      return EmailValidationError.empty;
    }

    if (!_emailRegex.hasMatch(value)) {
      return EmailValidationError.invalid;
    }

    return null;
  }
}
