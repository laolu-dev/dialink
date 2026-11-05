import 'package:dio/dio.dart';

/// An error from the API, read from its RFC 7807 `application/problem+json` body.
///
/// Branch on [type] (the slug after `urn:dialink:problem:`), never on [message].
final class ClientException implements Exception {
  const ClientException({
    required this.message,
    this.type,
    this.status,
    this.retryAfter,
    this.fieldErrors = const {},
  });

  final String message;

  /// Problem slug, e.g. `slot-unavailable`. Null for network errors.
  final String? type;

  final int? status;

  /// Seconds to wait, from the `Retry-After` header of a `429`.
  final int? retryAfter;

  /// Validation errors by field name, from a `400`.
  final Map<String, String> fieldErrors;

  bool get isUnauthorized => status == 401;

  /// Worth trying again unchanged: the network failed or the server did.
  /// A `429` is not: it says when to come back.
  bool get isTransient => status == null || status! >= 500;

  /// How providers that failed are retried: only [isTransient] errors, at
  /// most 3 times. Riverpod's default retries every exception 10 times,
  /// which repeats a `404` or `403` for nothing.
  static Duration? retryPolicy(int retryCount, Object error) =>
      error is ClientException && error.isTransient && retryCount < 3
      ? Duration(milliseconds: 500 * (1 << retryCount))
      : null;

  static const _problemPrefix = 'urn:dialink:problem:';

  factory ClientException.fromResponse(Response<dynamic>? response) {
    final status = response?.statusCode;
    final body = response?.data;
    final json = body is Map<String, dynamic>
        ? body
        : const <String, dynamic>{};

    final rawType = json['type'] as String?;
    final type = rawType != null && rawType.startsWith(_problemPrefix)
        ? rawType.substring(_problemPrefix.length)
        : null;

    final fieldErrors = <String, String>{
      for (final e in (json['errors'] as List<dynamic>? ?? const []))
        if (e is Map<String, dynamic>)
          e['field'] as String: e['message'] as String,
    };

    final retryAfter = int.tryParse(
      response?.headers.value('retry-after') ?? '',
    );

    return ClientException(
      type: type,
      status: status,
      retryAfter: retryAfter,
      fieldErrors: fieldErrors,
      message:
          _messageFor(type, status, retryAfter, fieldErrors) ??
          json['detail'] as String? ??
          'Something went wrong. Please try again.',
    );
  }

  factory ClientException.handleException(Object exception) {
    switch (exception) {
      case ClientException e:
        return e;

      case DioException dioError:
        switch (dioError.type) {
          case DioExceptionType.badResponse:
            return ClientException.fromResponse(dioError.response);

          case DioExceptionType.connectionTimeout ||
              DioExceptionType.receiveTimeout ||
              DioExceptionType.sendTimeout:
            return const ClientException(
              message:
                  'The server is taking too long to respond. Please try again.',
            );

          case DioExceptionType.connectionError:
            return const ClientException(
              message:
                  'Error establishing a connection to the server. Please try again',
            );

          case _:
            if (dioError.error is ClientException) {
              return dioError.error as ClientException;
            }
            return const ClientException(
              message: 'Something went wrong. Please try again.',
            );
        }

      default:
        return const ClientException(
          message: 'Something went wrong. Please try again.',
        );
    }
  }

  static String? _messageFor(
    String? type,
    int? status,
    int? retryAfter,
    Map<String, String> fieldErrors,
  ) {
    if (status == 429) {
      return retryAfter != null
          ? 'Too many attempts. Try again in $retryAfter seconds.'
          : 'Too many attempts. Please wait a moment and try again.';
    }

    return switch (type) {
      'invalid-credentials' => 'Email or password is incorrect.',
      'invalid-google-token' => 'Google sign-in failed. Try again.',
      'google-email-not-verified' =>
        "Your Google account's email isn't verified. Verify it with Google, or sign up with your email.",
      'google-sign-in-patients-only' =>
        'This account belongs to staff. Sign in with your email, password and authenticator.',
      'email-not-verified' => 'Confirm your email address to book.',
      'invalid-verification-link' =>
        'That code has expired or was already used. Request a new one.',
      'invalid-reset-link' =>
        'That reset code has expired or was already used. Request a new one.',
      'wrong-password' => 'Your current password is incorrect.',
      'slot-unavailable' =>
        'Someone else just took that time. Please pick another.',
      'booking-limit' => 'You already have 5 upcoming appointments.',
      'provider-booking-limit' =>
        'You already have 2 upcoming appointments with this provider.',
      'patient-overlap' => 'You already have an appointment at that time.',
      'too-soon' => 'Appointments must start at least 2 hours from now.',
      'too-far-ahead' => 'Appointments can be booked up to 90 days ahead.',
      'outside-schedule' || 'start-in-past' || 'unknown-provider' =>
        'That time is no longer available. Please pick another.',
      'invalid-transition' => 'This appointment can no longer be changed.',
      'not-deletable' =>
        'Only requested appointments can be deleted. Cancel it instead.',
      'already-started' => 'This appointment has already started.',
      'same-slot' => 'Pick a different time from the current one.',
      'email-already-registered' =>
        'An account with this email already exists. Try signing in.',
      'email-already-verified' => 'Your email is already confirmed.',
      'invalid-range' => 'Pick a shorter date range.',
      _ when fieldErrors.isNotEmpty =>
        fieldErrors.entries.map((e) => '${e.key} ${e.value}').join('\n'),
      _ => null,
    };
  }

  @override
  String toString() => message;
}
