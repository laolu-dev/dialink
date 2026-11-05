import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dialink/src/core/network/api_client.dart';
import 'package:dialink/src/core/network/auth_interceptor.dart';
import 'package:dialink/src/core/network/result.dart';
import 'package:dialink/src/core/storage/token_store.dart';
import 'package:dialink/src/data/auth/auth_repository.dart';
import 'package:dialink/src/data/users/models/user_model.dart';
import 'package:dialink/src/data/users/user_repository.dart';
import 'package:dialink/src/shared/controllers/session_controller.dart';

UserModel _user({String firstName = 'Ada'}) => UserModel(
  id: 'u1',
  email: 'ada@example.test',
  firstName: firstName,
  lastName: 'Obi',
  role: 'PATIENT',
  emailVerified: true,
);

/// An access token whose `sub` is `u1`.
final _accessToken = [
  'e30',
  base64Url.encode(utf8.encode(jsonEncode({'sub': 'u1'}))).replaceAll('=', ''),
  'sig',
].join('.');

/// Refreshes when the test says so.
class _FakeInterceptor extends AuthInterceptor {
  _FakeInterceptor(TokenStore tokens)
    : super(options: BaseOptions(), tokens: tokens, refreshPath: '/refresh');

  final answer = Completer<bool>();

  @override
  Future<bool> refresh() => answer.future;
}

class _FakeUsers extends UserRepository {
  _FakeUsers() : super(Dio());

  @override
  FutureResultOf<UserModel> getUser(String id) async =>
      Success(_user(firstName: 'Adaeze'));
}

void main() {
  late TokenStore tokens;
  late _FakeInterceptor interceptor;
  late ProviderContainer container;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({
      'dialink.refreshToken': 'refresh-0',
      'dialink.user': jsonEncode(_user().toJson()),
    });
    tokens = TokenStore();
    interceptor = _FakeInterceptor(tokens);
    container = ProviderContainer(
      overrides: [
        tokenStoreProvider.overrideWithValue(tokens),
        authInterceptorProvider.overrideWithValue(interceptor),
        authRepoProvider.overrideWithValue(
          AuthenticationRepository(Dio(), tokens),
        ),
        userRepoProvider.overrideWithValue(_FakeUsers()),
      ],
    );
    addTearDown(container.dispose);
  });

  test('opens on the saved account before the server answers', () async {
    container.listen(sessionProvider, (_, _) {});

    final user = await container.read(sessionProvider.future);

    expect(user?.firstName, 'Ada');
    expect(interceptor.answer.isCompleted, isFalse);
  });

  test('then shows the account the server returns', () async {
    container.listen(sessionProvider, (_, _) {});
    await container.read(sessionProvider.future);

    await tokens.save(accessToken: _accessToken, refreshToken: 'refresh-1');
    interceptor.answer.complete(true);
    await pumpEventQueue();

    expect(container.read(sessionProvider).value?.firstName, 'Adaeze');
  });

  test('offline, it keeps the saved account', () async {
    container.listen(sessionProvider, (_, _) {});
    await container.read(sessionProvider.future);

    interceptor.answer.complete(false);
    await pumpEventQueue();

    final session = container.read(sessionProvider);
    expect(session.hasError, isFalse);
    expect(session.value?.firstName, 'Ada');
  });

  test('signing out forgets the saved account', () async {
    await tokens.clear();
    expect(await tokens.readUser(), isNull);
  });
}
