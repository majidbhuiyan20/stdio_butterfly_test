abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  NetworkFailure() : super('No internet connection');
}

class ValidationFailure extends Failure {
  ValidationFailure(super.message);
}
