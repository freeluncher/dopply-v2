import 'package:equatable/equatable.dart';

/// Abstract base class for all failures in the application.
///
/// All failures should extend this class and implement the `props` method.
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Failure representing server-related errors.
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

/// Failure representing cache-related errors.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Failure representing network-related errors.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Failure representing Bluetooth-related errors.
class BluetoothFailure extends Failure {
  const BluetoothFailure(super.message);
}

/// Failure representing unknown or unexpected errors.
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
