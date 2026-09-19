import 'package:dio/dio.dart';

final class ClientException implements Exception {
  const ClientException({required this.message});
  final String message;

  factory ClientException.badResponse(Map<String, dynamic> json) =>
      ClientException(
        message: json['message'] as String,
      );

  factory ClientException.handleException(Object exception) {
    switch (exception) {
      case DioException dioError:
        switch (dioError.type) {
          case DioExceptionType.badResponse:
            return ClientException.badResponse(
                exception.response?.data as Map<String, dynamic>);

          case DioExceptionType.connectionError:
            return ClientException(
              message:
                  'Error establishing a connection to the server. Please try again',
            );
          case _:
            return ClientException(message: dioError.error.toString());
        }

      default:
        return ClientException(message: exception.toString());
    }
  }

  @override
  String toString() => message;
}
