import 'package:intl/intl.dart';

import 'package:todo_flutter_mobile_app/features/authentication/a_domain/entities/user_entity.dart';

import '../../a_domain/entities/enums.dart';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String avatarUrl;
  final DateTime dateOfBirth;
  final Sex sex;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.avatarUrl,
    required this.dateOfBirth,
    required this.sex,
  });

  /// Factory để parse dữ liệu kết hợp từ:
  /// 1. Supabase User Object (cho id, email)
  /// 2. Data từ bảng 'profiles' (cho full_name, sex...)
  factory UserModel.fromSupabase({
    required Map<String, dynamic> profileJson,
    required String email,
    required String uid,
    required String accessToken,
    required String refreshToken,
  }) {
    return UserModel(
      id: uid,
      email: email,
      fullName: profileJson['full_name'] as String? ?? '',
      avatarUrl: profileJson['avatar_url'] as String? ?? '',
      // Supabase trả date dạng string 'yyyy-MM-dd'
      dateOfBirth: DateTime.parse(profileJson['date_of_birth']),
      sex: Sex.fromString(profileJson['sex'] as String),
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      fullName: fullName,
      avatarUrl: avatarUrl,
      dateOfBirth: dateOfBirth,
      sex: sex,
    );
  }

  /// Chuyển đổi thành Json (nếu cần cache local)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'date_of_birth': DateFormat('yyyy-MM-dd').format(dateOfBirth),
      'sex': sex.toJson(),
    };
  }
}
