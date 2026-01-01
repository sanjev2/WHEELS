import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// Local Database Failure
class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure({
    String message = 'Local database operation failed',
  }) : super(message);
}

// API Failure with status code
class ApiFailure extends Failure {
  final int? statusCode;

  const ApiFailure({required String message, this.statusCode}) : super(message);

  @override
  List<Object?> get props => [message, statusCode];
}

// Auth Failure
class AuthFailure extends Failure {
  const AuthFailure({String message = 'Authentication failed'})
    : super(message);
}

// Validation Failure
class ValidationFailure extends Failure {
  const ValidationFailure({String message = 'Validation failed'})
    : super(message);
}
