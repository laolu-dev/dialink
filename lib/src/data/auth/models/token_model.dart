/// What a sign-in returns: tokens for a patient, or an MFA challenge for a
/// provider or admin, who must use their own app.
sealed class LoginOutcome {
  const LoginOutcome();

  factory LoginOutcome.fromJson(Map<String, dynamic> json) =>
      json.containsKey('mfaRequired')
      ? const MfaRequired()
      : TokenPair.fromJson(json);
}

final class TokenPair extends LoginOutcome {
  const TokenPair({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;

  factory TokenPair.fromJson(Map<String, dynamic> json) => TokenPair(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
  );
}

final class MfaRequired extends LoginOutcome {
  const MfaRequired();
}
