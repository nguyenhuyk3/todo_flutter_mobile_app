import 'enums.dart';

class AppUser {
  final String id;
  final String email;
  final String fullName;
  final String avatarUrl;
  final DateTime dateOfBirth;
  final Sex sex;

  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    required this.avatarUrl,
    required this.dateOfBirth,
    required this.sex,
  });
}
