import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../auth/domain/user.dart';
import '../domain/user_repository.dart';

@lazySingleton
class GetDevelopersUseCase {
  final UserRepository repository;
  GetDevelopersUseCase(this.repository);
  Future<Either<Failure, List<User>>> call() => repository.getDevelopers();
}
