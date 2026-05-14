import 'package:equatable/equatable.dart';

/// Base failure class for functional error handling via `dartz`.
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'A server error occurred. Please try again later.'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Unable to load cached data.'});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'No internet connection. Please check your network.'});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'An unexpected error occurred.'});
}
