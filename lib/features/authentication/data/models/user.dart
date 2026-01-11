import 'package:intl/intl.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/enums.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.avatarUrl,
    required super.dateOfBirth,
    required super.sex,
  });

  /// Factory để parse dữ liệu kết hợp từ:
  /// 1. Supabase User Object (cho id, email)
  /// 2. Data từ bảng 'profiles' (cho full_name, sex...)
  factory UserModel.fromSupabase(
    Map<String, dynamic> profileJson,
    String email,
    String uid,
  ) {
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
