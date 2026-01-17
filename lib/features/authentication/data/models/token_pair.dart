class TokenPair {
  String accessToken;
  String refreshToken;

  TokenPair({required this.accessToken, required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {'access_token': accessToken, 'refresh_token': refreshToken};
  }
}
