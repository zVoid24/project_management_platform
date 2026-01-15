import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../domain/project.dart';
import '../domain/project_repository.dart';

@lazySingleton
class GetProjectsUseCase {
  final ProjectRepository repository;
  GetProjectsUseCase(this.repository);
  Future<Either<Failure, List<Project>>> call() => repository.getProjects();
}

@lazySingleton
class CreateProjectUseCase {
  final ProjectRepository repository;
  CreateProjectUseCase(this.repository);
  Future<Either<Failure, Project>> call(String title, String description) =>
      repository.createProject(title, description);
}
