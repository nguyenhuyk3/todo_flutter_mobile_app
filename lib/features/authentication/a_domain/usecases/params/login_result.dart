import 'package:todo_flutter_mobile_app/features/authentication/a_domain/entities/authentication_session.dart';

import '../../entities/user_entity.dart';

class LoginResult {
  final UserEntity user;
  final AuthenticationSession session;

  const LoginResult({required this.user, required this.session});
}
