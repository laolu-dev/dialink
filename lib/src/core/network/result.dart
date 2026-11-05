import 'package:dialink/src/core/network/api_exception.dart';

sealed class Result<S, F> {
  const Result();

  C fold<C>(C Function(S success) onSuccess, C Function(F failure) onFailure) =>
      _match<C>(onSuccess, onFailure);

  C _match<C>(C Function(S success) onLeft, C Function(F failure) onRight);
}

class Success<S, F> extends Result<S, F> {
  const Success(this._value);

  final S _value;

  S get value => _value;

  @override
  C _match<C>(C Function(S success) onLeft, C Function(F failure) onRight) =>
      onLeft(_value);
}

class Failure<S, F> extends Result<S, F> implements Exception {
  const Failure(this._value);

  final F _value;

  F get value => _value;

  @override
  C _match<C>(C Function(S success) onLeft, C Function(F failure) onRight) =>
      onRight(_value);
}

/// Runs an API call and turns any error into a [Failure] with a [ClientException].
Future<Result<T, ClientException>> guard<T>(Future<T> Function() call) async {
  try {
    return Success(await call());
  } catch (e) {
    return Failure(ClientException.handleException(e));
  }
}

typedef FutureResultOf<T> = Future<Result<T, ClientException>>;
