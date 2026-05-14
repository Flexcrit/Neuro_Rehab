import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Abstract contract for all domain use cases.
///
/// [Type] — The success return type.
/// [Params] — The input parameter type (use [NoParams] for parameterless use cases).
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Marker class for use cases that require no parameters.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object> get props => [];
}
