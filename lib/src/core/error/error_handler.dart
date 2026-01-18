import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'exceptions.dart';
import 'failures.dart';

/// Provider for the [ErrorHandler] service.
/// Kept alive to ensure error stream is always active.
final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return ErrorHandler();
});

/// A stream of [Failure]s that the UI can listen to.
final errorStreamProvider = StreamProvider<Failure>((ref) {
  return ref.watch(errorHandlerProvider).errorStream;
});

class ErrorHandler {
  final _controller = StreamController<Failure>.broadcast();

  Stream<Failure> get errorStream => _controller.stream;

  /// Centralized method to handle ANY error.
  /// Converts exceptions to [Failure] and emits them to the stream.
  void handleError(Object error, [StackTrace? stackTrace]) {
    // Log error here (e.g. Crashlytics)
    print('ErrorHandler caught: $error\n$stackTrace');

    final failure = _mapExceptionToFailure(error);
    _controller.add(failure);
  }

  Failure _mapExceptionToFailure(Object error) {
    if (error is Failure) return error;

    if (error is ServerException) {
      return ServerFailure(error.message, statusCode: error.statusCode);
    }

    if (error is BluetoothException) {
      return BluetoothFailure(error.message);
    }

    if (error is SocketException) {
      return const NetworkFailure('No internet connection');
    }

    if (error is AuthException) {
      return ServerFailure(
        error.message,
        statusCode: int.tryParse(error.statusCode ?? '401'),
      );
    }

    if (error is PostgrestException) {
      return ServerFailure(
        error.message,
        statusCode: int.tryParse(error.code ?? '500'),
      );
    }

    // Default fallback
    return UnknownFailure(error.toString());
  }

  void dispose() {
    _controller.close();
  }
}
