import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import 'task.dart';
import 'task_repository.dart';

@lazySingleton
class GetAssignedTasksUseCase {
  final TaskRepository repository;
  GetAssignedTasksUseCase(this.repository);
  Future<Either<Failure, List<Task>>> call() => repository.getAssignedTasks();
}

@lazySingleton
class GetTasksByProjectUseCase {
  final TaskRepository repository;
  GetTasksByProjectUseCase(this.repository);
  Future<Either<Failure, List<Task>>> call(int projectId) =>
      repository.getTasksByProject(projectId);
}

@lazySingleton
class CreateTaskUseCase {
  final TaskRepository repository;
  CreateTaskUseCase(this.repository);
  Future<Either<Failure, Task>> call(Task task) => repository.createTask(task);
}

@lazySingleton
class SubmitTaskUseCase {
  final TaskRepository repository;
  SubmitTaskUseCase(this.repository);
  Future<Either<Failure, Task>> call(
    int taskId,
    double timeSpent,
    String? filePath,
  ) => repository.submitTask(taskId, timeSpent, filePath);
}
