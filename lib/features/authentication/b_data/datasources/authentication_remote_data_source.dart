import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/others.dart';
import '../../a_domain/entities/authentication_session.dart';
import '../../a_domain/usecases/params/login_result_param.dart';
import '../../a_domain/usecases/params/registration_param.dart';
import '../models/user_model.dart';

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

  Future<LoginResultParam> login({
    required String email,
    required String password,
  }) async {
    signOut();
    // 1. Đăng nhập để lấy Session & Token
    final authResponse = await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (authResponse.user == null) {
      throw const AuthException('Đăng nhập thất bại');
    }

    final session = authResponse.session;
    final accessToken = session?.accessToken;
    final refreshToken = session?.refreshToken;
    // 2. Query thông tin từ bảng profiles (Vì AuthUser chỉ có id & email)
    final profileData =
        await _supabaseClient
            .from('profiles')
            .select()
            .eq('id', authResponse.user!.id)
            .single();
    // 3. Merge data thành Model hoàn chỉnh
    final userModel = UserModel.fromSupabase(
      profileJson: profileData,
      email: authResponse.user!.email!,
      uid: authResponse.user!.id,
      accessToken: accessToken!,
      refreshToken: refreshToken!,
    );

    return LoginResultParam(
      user: userModel.toEntity(),
      session: AuthenticationSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
      ),
    );
  }

  Future<void> signOut() async {
    await Future.wait([
      SECURE_STORAGE.clearAll(),

      _supabaseClient.auth.signOut(),
    ]);
  }

  Future<LoginResultParam?> tryAutoLogin({
    required String refreshToken,
    required String userId,
  }) async {
    // Hàm setSession này sẽ kiểm tra xem token còn hạn không và cấp access token mới nếu cần
    final response = await _supabaseClient.auth.setSession(refreshToken);
    // Nếu session null nghĩa là refresh token đã hết hạn hoặc bị thu hồi
    if (response.session == null || response.user == null) {
      return null;
    }

    final profileData =
        await _supabaseClient
            .from('profiles')
            .select()
            .eq('id', response.user!.id)
            .single();
    final newAccessToken = response.session!.accessToken;
    final newRefreshToken = response.session!.refreshToken;
    final userModel = UserModel.fromSupabase(
      profileJson: profileData,
      email: response.user!.email!,
      uid: response.user!.id,
      accessToken: newAccessToken,
      refreshToken: newRefreshToken!,
    );

    return LoginResultParam(
      user: userModel.toEntity(),
      session: AuthenticationSession(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      ),
    );
  }
}
