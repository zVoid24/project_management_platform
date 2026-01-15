import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../domain/project.dart';
import '../domain/project_repository.dart';
import 'project_remote_data_source.dart';

@LazySingleton(as: ProjectRepository)
class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;

  ProjectRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Project>>> getProjects() async {
    try {
      final projects = await remoteDataSource.getProjects();
      return Right(projects);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }

  @override
  Future<Either<Failure, Project>> createProject(
    String title,
    String description,
  ) async {
    try {
      final project = await remoteDataSource.createProject(title, description);
      return Right(project);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }
}
