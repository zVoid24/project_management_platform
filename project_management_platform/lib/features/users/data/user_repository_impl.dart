import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../auth/domain/user.dart';
import '../domain/user_repository.dart';
import '../data/user_remote_data_source.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<User>>> getDevelopers() async {
    try {
      final users = await remoteDataSource.getDevelopers();
      return Right(users);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }
}
