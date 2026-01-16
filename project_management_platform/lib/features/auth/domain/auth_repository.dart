import 'package:dartz/dartz.dart'; // Will use dartz for Either
import 'user.dart';
import '../../../../core/errors/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> register(
    String email,
    String password,
    String role,
    String? fullName,
  );
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, List<User>>> getAllUsers();
}
