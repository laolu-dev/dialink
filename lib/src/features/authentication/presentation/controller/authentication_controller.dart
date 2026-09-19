import 'package:dialink/src/features/authentication/data/auth_repository.dart';
import 'package:dialink/src/features/authentication/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'authentication_controller.g.dart';

@riverpod
class AuthenticationController extends _$AuthenticationController {
  late final AuthenticationRepository _repository;

  @override
  FutureOr<UserModel?> build() {
    _repository = ref.watch(authRepoProvider);
    return null;
  }

  void createAccount(Map<String, dynamic> payload) async {
    state = AsyncLoading();

    final response = await _repository.createAccount(payload);
    response.fold(
      (success) => state = AsyncData(null),
      (exception) => state = AsyncError(exception.message, StackTrace.current),
    );
  }

  void login(Map<String, dynamic> payload) async {
    state = AsyncLoading();

    final response = await _repository.login(payload);
    response.fold(
      (success) => state = AsyncData(success.data),
      (exception) => state = AsyncError(exception.message, StackTrace.current),
    );
  }
}
