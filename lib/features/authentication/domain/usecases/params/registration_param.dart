import '../../entities/enums.dart';

class RegistrationParams {
  final String email;
  final String password;
  final String fullName;
  final DateTime dateOfBirth;
  final Sex sex;
  final String avatarUrl;

  RegistrationParams({
    required this.email,
    required this.password,
    required this.fullName,
    required this.dateOfBirth,
    required this.sex,
    this.avatarUrl = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'full_name': fullName,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'sex': sex.name,
      'avatar_url': avatarUrl,
    };
  }
}
