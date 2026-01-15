import 'package:dartz/dartz.dart' hide Task;
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../domain/task.dart';
import '../domain/task_repository.dart';
import 'task_remote_data_source.dart';

@LazySingleton(as: TaskRepository)
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  TaskRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Task>>> getAssignedTasks() async {
    try {
      final tasks = await remoteDataSource.getAssignedTasks();
      return Right(tasks);
    } on Failure catch (e) {
      return Left(e);
    } catch (_) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }

  @override
  Future<Either<Failure, List<Task>>> getTasksByProject(int projectId) async {
    try {
      final tasks = await remoteDataSource.getTasksByProject(projectId);
      return Right(tasks);
    } on Failure catch (e) {
      return Left(e);
    } catch (_) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }

  @override
  Future<Either<Failure, Task>> createTask(Task task) async {
    try {
      final result = await remoteDataSource.createTask(task);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (_) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }

  @override
  Future<Either<Failure, Task>> updateStatus(
    int taskId,
    TaskStatus status,
  ) async {
    try {
      final result = await remoteDataSource.updateStatus(taskId, status);
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (_) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }

  @override
  Future<Either<Failure, Unit>> submitTask(
    int taskId,
    double timeSpent,
    String? filePath,
  ) async {
    try {
      await remoteDataSource.submitTask(taskId, timeSpent, filePath);
      return const Right(unit);
    } on Failure catch (e) {
      return Left(e);
    } catch (_) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }

  @override
  Future<Either<Failure, double>> payForTask(int taskId) async {
    try {
      final amount = await remoteDataSource.payForTask(taskId);
      return Right(amount);
    } on Failure catch (e) {
      return Left(e);
    } catch (_) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }

  @override
  Future<Either<Failure, Unit>> downloadSolution(
    int taskId,
    String savePath,
  ) async {
    try {
      await remoteDataSource.downloadSolution(taskId, savePath);
      return const Right(unit);
    } on Failure catch (e) {
      return Left(e);
    } catch (_) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }
}
