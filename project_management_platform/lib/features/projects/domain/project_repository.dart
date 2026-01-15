import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import 'project.dart';

abstract class ProjectRepository {
  Future<Either<Failure, List<Project>>> getProjects();
  Future<Either<Failure, Project>> createProject(
    String title,
    String description,
  );
}
