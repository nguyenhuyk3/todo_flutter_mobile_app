// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:todo_flutter_mobile_app/core/constants/others.dart';
import 'package:todo_flutter_mobile_app/features/authentication/data/models/user.dart';

import '../../../../core/constants/keys.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/supabase_error_mapper.dart';
import '../../domain/repositories/authentication.dart';
import '../../domain/usecases/params/registration_param.dart';
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

  Future<void> _saveUserToSecureStorage({required UserModel user}) async {
    await Future.wait([
      SECURE_STORAGE.write(
        key: SecureStorageKeys.ACCESS_TOKEN,
        value: user.tokenPair.accessToken,
      ),
      SECURE_STORAGE.write(
        key: SecureStorageKeys.REFRESH_TOKEN,
        value: user.tokenPair.refreshToken,
      ),
      SECURE_STORAGE.write(key: SecureStorageKeys.USER_ID, value: user.id),
      SECURE_STORAGE.write(
        key: SecureStorageKeys.USER_EMAIL,
        value: user.email,
      ),
      SECURE_STORAGE.write(
        key: SecureStorageKeys.USER_FULL_NAME,
        value: user.fullName,
      ),
      SECURE_STORAGE.write(
        key: SecureStorageKeys.USER_AVATAR_URL,
        value: user.avatarUrl,
      ),
      SECURE_STORAGE.write(
        key: SecureStorageKeys.USER_DATE_OF_BIRTH,
        value: user.dateOfBirth.toIso8601String(),
      ),
      SECURE_STORAGE.write(
        key: SecureStorageKeys.USER_SEX,
        value: user.sex.toJson(),
      ),
    ]);
  }

  @override
  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      SECURE_STORAGE.clearAll();

      final data = await _authenticationRemoteDataSource.login(
        email: email,
        password: password,
      );

      _saveUserToSecureStorage(user: data);

      return Right(data);
    } on AuthException catch (e) {
      return Left(Failure(error: mapAuthException(e), details: e));
    } on PostgrestException catch (e) {
      return Left(Failure(error: mapPostgrestException(e), details: e));
    } catch (e) {
      return Left(Failure(error: ErrorInformation.UNDEFINED_ERROR, details: e));
    }
  }
}
