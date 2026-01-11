import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/registration_params.dart';
import '../models/user.dart';

class AuthenticationRemoteDataSource {
  final SupabaseClient _supabaseClient;

  AuthenticationRemoteDataSource({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  Future<bool> checkEmailExists({required String email}) async {
    return await _supabaseClient.rpc(
      'check_email_exists',
      params: {'email_check': email},
    );
  }

  Future<void> resendOTP({required String email, required OtpType type}) async {
    await _supabaseClient.auth.resend(email: email, type: type);
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String otp,
    required OtpType type,
  }) async {
    await _supabaseClient.auth.verifyOTP(email: email, token: otp, type: type);
  }

  Future<void> register({required RegistrationParams params}) async {
    await _supabaseClient.auth.signUp(
      email: params.email,
      password: params.password,
      data: {
        'full_name': params.fullName,
        'avatar_url': params.avatarUrl,
        // Trigger SQL cast (..)::date, nên cần format chuỗi chuẩn yyyy-MM-dd
        'dob': DateFormat('yyyy-MM-dd').format(params.dateOfBirth),
        // Trigger SQL cast (..)::sex
        'sex': params.sex.name,
      },
    );
  }

  Future<void> sendForgotPasswordOTP({required String email}) async {
    await _supabaseClient.auth.resetPasswordForEmail(email);
  }

  Future<void> updatePassword({required String newPassword}) async {
    // 1. Cập nhật mật khẩu mới
    await _supabaseClient.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    // 2. Đăng xuất người dùng ngay lập tức
    // Sử dụng scope: SignOutScope.global để đăng xuất khỏi TẤT CẢ các thiết bị (nếu có)
    // Đây là cách bảo mật nhất khi đổi mật khẩu (phòng trường hợp bị hack nick)
    await _supabaseClient.auth.signOut(scope: SignOutScope.global);
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // 1. Đăng nhập để lấy Session & Token
    final authResponse = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (authResponse.user == null) {
      throw const AuthException('Đăng nhập thất bại.');
    }
    // 2. Query thông tin từ bảng profiles (Vì AuthUser chỉ có id & email)
    final profileData =
        await _supabaseClient
            .from('profiles')
            .select()
            .eq('id', authResponse.user!.id)
            .single();
    // 3. Merge data thành Model hoàn chỉnh
    return UserModel.fromSupabase(
      profileData,
      authResponse.user!.email!,
      authResponse.user!.id,
    );
  }

  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }
}
