import 'enums.dart';

class UserEntity {
  final String id;
  final String email;
  final String fullName;
  final String avatarUrl;
  final DateTime dateOfBirth;
  final Sex sex;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.avatarUrl,
    required this.dateOfBirth,
    required this.sex,
  });
}
