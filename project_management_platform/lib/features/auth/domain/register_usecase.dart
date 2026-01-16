import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart';

@lazySingleton
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, User>> call(
    String email,
    String password,
    String role,
    String? fullName,
  ) async {
    return await repository.register(email, password, role, fullName);
  }
}
