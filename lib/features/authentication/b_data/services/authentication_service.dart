import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/keys.dart';
import '../../../../core/constants/others.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/supabase_error_mapper.dart';
import '../../a_domain/repositories/authentication.dart';
import '../../a_domain/usecases/params/login_result_param.dart';
import '../../a_domain/usecases/params/registration_param.dart';
import '../datasources/authentication_remote_data_source.dart';

class AuthenticationService implements IAuthenticationRepository {
  final AuthenticationRemoteDataSource _authenticationRemoteDataSource;

  AuthenticationService({
    required AuthenticationRemoteDataSource authenticationRemoteDataSource,
  }) : _authenticationRemoteDataSource = authenticationRemoteDataSource;

  @override
  Future<Either<Failure, bool>> checkEmailExists({
    required String email,
  }) async {
    try {
      final exists = await _authenticationRemoteDataSource.checkEmailExists(
        email: email,
      );

      if (!exists) {
        return Left(Failure(error: ErrorInformation.EMAIL_NOT_EXISTS));
      }

      return const Right(true);
    } catch (e) {
      return Left(Failure(error: ErrorInformation.UNDEFINED_ERROR, details: e));
    }
  }

  @override
  Future<Either<Failure, bool>> resendOTP({
    required String email,
    required OtpType type,
  }) async {
    try {
      await _authenticationRemoteDataSource.resendOTP(email: email, type: type);

      return Right(true);
    } catch (e) {
      return Left(Failure(error: ErrorInformation.UNDEFINED_ERROR, details: e));
    }
  }

  @override
  Future<Either<Failure, Object>> verifyOTP({
    required String email,
    required String otp,
    required OtpType type,
  }) async {
    try {
      await _authenticationRemoteDataSource.verifyEmailOtp(
        email: email,
        otp: otp,
        type: type,
      );

      return Right(Object());
    } on AuthException catch (e) {
      return Left(Failure(error: mapAuthException(e), details: e));
    } catch (e) {
      return Left(Failure(error: ErrorInformation.UNDEFINED_ERROR, details: e));
    }
  }

  @override
  Future<Either<Failure, bool>> register(RegistrationParams params) async {
    try {
      await _authenticationRemoteDataSource.register(params: params);

      return const Right(true);
    } on PostgrestException catch (e) {
      return Left(Failure(error: mapPostgrestException(e), details: e));
    } on AuthException catch (e) {
      return Left(Failure(error: mapAuthException(e), details: e));
    } catch (e) {
      return Left(Failure(error: ErrorInformation.UNDEFINED_ERROR, details: e));
    }
  }

  @override
  Future<Either<Failure, bool>> sendForgotPasswordOTP({
    required String email,
  }) async {
    try {
      await _authenticationRemoteDataSource.sendForgotPasswordOTP(email: email);

      return Right(true);
    } on AuthException catch (e) {
      return Left(Failure(error: mapAuthException(e), details: e));
    } catch (e) {
      return Left(Failure(error: ErrorInformation.UNDEFINED_ERROR, details: e));
    }
  }

  @override
  Future<Either<Failure, bool>> updatePassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      await _authenticationRemoteDataSource.updatePassword(
        newPassword: newPassword,
      );

      return const Right(true);
    } on PostgrestException catch (e) {
      return Left(Failure(error: mapPostgrestException(e), details: e));
    } on AuthException catch (e) {
      return Left(Failure(error: mapAuthException(e), details: e));
    } catch (e) {
      return Left(Failure(error: ErrorInformation.UNDEFINED_ERROR, details: e));
    }
  }

  Future<void> _saveUserToSecureStorage({
    required LoginResultParam loginResult,
  }) async {
    await Future.wait([
      SECURE_STORAGE.write(
        key: SecureStorageKeys.ACCESS_TOKEN,
        value: loginResult.session.accessToken,
      ),
      SECURE_STORAGE.write(
        key: SecureStorageKeys.REFRESH_TOKEN,
        value: loginResult.session.refreshToken,
      ),
      SECURE_STORAGE.write(
        key: SecureStorageKeys.USER_ID,
        value: loginResult.user.id,
      ),
      SECURE_STORAGE.write(
        key: SecureStorageKeys.USER_EMAIL,
        value: loginResult.user.email,
      ),
      SECURE_STORAGE.write(
        key: SecureStorageKeys.USER_FULL_NAME,
        value: loginResult.user.fullName,
      ),
      SECURE_STORAGE.write(
        key: SecureStorageKeys.USER_AVATAR_URL,
        value: loginResult.user.avatarUrl,
      ),
      SECURE_STORAGE.write(
        key: SecureStorageKeys.USER_DATE_OF_BIRTH,
        value: loginResult.user.dateOfBirth.toIso8601String(),
      ),
      SECURE_STORAGE.write(
        key: SecureStorageKeys.USER_SEX,
        value: loginResult.user.sex.toJson(),
      ),
    ]);
  }

  @override
  Future<Either<Failure, LoginResultParam>> login({
    required String email,
    required String password,
  }) async {
    try {
      SECURE_STORAGE.clearAll();

      final data = await _authenticationRemoteDataSource.login(
        email: email,
        password: password,
      );

      _saveUserToSecureStorage(loginResult: data);

      return Right(data);
    } on AuthException catch (e) {
      return Left(Failure(error: mapAuthException(e), details: e));
    } on PostgrestException catch (e) {
      return Left(Failure(error: mapPostgrestException(e), details: e));
    } catch (e) {
      return Left(Failure(error: ErrorInformation.UNDEFINED_ERROR, details: e));
    }
  }

  @override
  Future<Either<Failure, LoginResultParam>> tryAutoLogin() async {
    try {
      final refreshToken = await SECURE_STORAGE.read(
        key: SecureStorageKeys.REFRESH_TOKEN,
      );
      final userId = await SECURE_STORAGE.read(key: SecureStorageKeys.USER_ID);

      if (refreshToken == null || userId == null) {
        return Left(Failure(error: ErrorInformation.TRY_AUTO_LOGIN_FAILED));
      }

      final data = await _authenticationRemoteDataSource.tryAutoLogin(
        refreshToken: refreshToken,
        userId: userId,
      );

      if (data != null) {
        await SECURE_STORAGE.clearAll(); // Xóa dữ liệu rác

        _saveUserToSecureStorage(loginResult: data);

        return Right(data);
      }

      return Left(Failure(error: ErrorInformation.TRY_AUTO_LOGIN_FAILED));
    } on AuthException catch (e) {
      return Left(Failure(error: mapAuthException(e), details: e));
    } on PostgrestException catch (e) {
      return Left(Failure(error: mapPostgrestException(e), details: e));
    } catch (e) {
      return Left(Failure(error: ErrorInformation.UNDEFINED_ERROR, details: e));
    }
  }
}
