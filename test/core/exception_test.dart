import 'package:dialink/src/core/api/exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

Response<dynamic> _response(
  int status,
  Map<String, dynamic> body, {
  Map<String, List<String>> headers = const {},
}) => Response(
  requestOptions: RequestOptions(path: '/x'),
  statusCode: status,
  data: body,
  headers: Headers.fromMap(headers),
);

void main() {
  test('reads the problem slug and gives a friendly message', () {
    final e = ClientException.fromResponse(
      _response(409, {
        'type': 'urn:dialink:problem:slot-unavailable',
        'title': 'Slot unavailable',
        'status': 409,
        'detail': 'raw server text',
      }),
    );

    expect(e.type, 'slot-unavailable');
    expect(e.status, 409);
    expect(e.message, isNot('raw server text'));
  });

  test('falls back to detail for an unknown slug', () {
    final e = ClientException.fromResponse(
      _response(422, {
        'type': 'urn:dialink:problem:something-new',
        'detail': 'Server explanation.',
      }),
    );

    expect(e.type, 'something-new');
    expect(e.message, 'Server explanation.');
  });

  test('reads Retry-After on a 429', () {
    final e = ClientException.fromResponse(
      _response(
        429,
        {'type': 'about:blank'},
        headers: {
          'retry-after': ['12'],
        },
      ),
    );

    expect(e.retryAfter, 12);
    expect(e.message, contains('12 seconds'));
  });

  test('collects validation errors by field', () {
    final e = ClientException.fromResponse(
      _response(400, {
        'type': 'about:blank',
        'errors': [
          {'field': 'phone', 'message': 'must be E.164'},
        ],
      }),
    );

    expect(e.type, isNull);
    expect(e.fieldErrors, {'phone': 'must be E.164'});
  });

  test('survives a body that is not JSON', () {
    final e = ClientException.handleException(
      DioException.badResponse(
        statusCode: 502,
        requestOptions: RequestOptions(path: '/x'),
        response: Response(
          requestOptions: RequestOptions(path: '/x'),
          statusCode: 502,
          data: '<html>Bad gateway</html>',
        ),
      ),
    );

    expect(e.status, 502);
    expect(e.message, isNotEmpty);
  });

  group('retryPolicy', () {
    test('retries network and server errors a few times', () {
      const offline = ClientException(message: 'offline');
      const server = ClientException(message: 'down', status: 503);

      expect(ClientException.retryPolicy(0, offline), isNotNull);
      expect(ClientException.retryPolicy(2, server), isNotNull);
      expect(ClientException.retryPolicy(3, server), isNull);
    });

    test('does not retry client errors, rate limits or other failures', () {
      for (final status in [400, 401, 403, 404, 409, 422, 429]) {
        expect(
          ClientException.retryPolicy(
            0,
            ClientException(message: 'x', status: status),
          ),
          isNull,
          reason: '$status',
        );
      }
      expect(ClientException.retryPolicy(0, StateError('bug')), isNull);
    });
  });
}
