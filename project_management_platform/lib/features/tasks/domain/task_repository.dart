import 'package:dartz/dartz.dart' hide Task;
import '../../../../core/errors/failures.dart';
import 'task.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<Task>>> getAssignedTasks();
  Future<Either<Failure, List<Task>>> getTasksByProject(int projectId);
  Future<Either<Failure, Task>> createTask(Task task);
  Future<Either<Failure, Task>> updateStatus(int taskId, TaskStatus status);
  Future<Either<Failure, Unit>> submitTask(
    int taskId,
    double timeSpent,
    String? filePath,
  );
}
