import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../domain/auth_repository.dart';
import '../domain/user.dart';

@lazySingleton
class GetAllUsersUseCase {
  final AuthRepository repository;

  GetAllUsersUseCase(this.repository);

  Future<Either<Failure, List<User>>> call() async {
    return await repository.getAllUsers();
  }
}
