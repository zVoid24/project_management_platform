import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../auth/domain/user.dart';

abstract class UserRepository {
  Future<Either<Failure, List<User>>> getDevelopers();
}
