class ServerException implements Exception {
  final String? message;
  ServerException({this.message = "ServerException"});
}

class ServerExceptionForCode500 implements Exception {
  final String? message;
  final int? statusCode;
  ServerExceptionForCode500(
      {this.message = "ServerExceptionForCode500", this.statusCode});
}

class Unauth implements Exception {
  final String? message;
  final int? statusCode;
  Unauth({this.message = "Unauth", this.statusCode});
}

class OperationFailedException implements Exception {
  final String? message;

  OperationFailedException({this.message = "OperationFailedException"});
}

class TryAgainException implements Exception {
  final String? message;
  final int tryCount;
  TryAgainException(
      {this.message = "TryAgainException", required this.tryCount});
}
