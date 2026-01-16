import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../domain/task.dart';
import '../domain/task_repository.dart';

@lazySingleton
class GetAllTasksUseCase {
  final TaskRepository repository;

  GetAllTasksUseCase(this.repository);

  Future<Either<Failure, List<Task>>> call() async {
    return await repository.getAllTasks();
  }
}
