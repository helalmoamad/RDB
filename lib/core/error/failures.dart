abstract class Failure {
  final String message;
  final int statusCode;
  const Failure(this.message, this.statusCode);
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure(String s, {String? message, required int statusCode})
      : super(message ?? "ServerFailure", statusCode);
}

class OperationFailedFailure extends Failure {
  const OperationFailedFailure({String? message, required int statusCode})
      : super(message ?? "OperationFailedFailure", statusCode);
}

class DioFailure extends Failure {
  const DioFailure({String? message, required int statusCode})
      : super(message ?? "DioFailure", statusCode);
}

class TryAgainFailure extends Failure {
  final int tryCount;
  const TryAgainFailure(
      {String? message, required this.tryCount, required int statusCode})
      : super(message ?? "TryAgainFailure", statusCode);
}
