import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/auth_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, AuthEntity>> login(String email, String password);
  Future<Either<Failure, AuthEntity>> signup(AuthEntity user);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, AuthEntity?>> getCurrentUser();
}
