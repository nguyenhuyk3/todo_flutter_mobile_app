class AuthenticationSession {
  final String accessToken;
  final String refreshToken;

  const AuthenticationSession({
    required this.accessToken,
    required this.refreshToken,
  });
}
