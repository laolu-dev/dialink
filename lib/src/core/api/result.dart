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
