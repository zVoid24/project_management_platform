import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../domain/task.dart';
import 'task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getAssignedTasks();
  Future<List<TaskModel>> getTasksByProject(int projectId);
  Future<TaskModel> createTask(Task task);
  Future<TaskModel> updateStatus(int taskId, TaskStatus status);
  Future<void> submitTask(int taskId, double timeSpent, String? filePath);
}

@LazySingleton(as: TaskRemoteDataSource)
class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio client;
  TaskRemoteDataSourceImpl(this.client);

  @override
  Future<List<TaskModel>> getAssignedTasks() async {
    try {
      final response = await client.get('/tasks/assigned');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => TaskModel.fromJson(e))
            .toList();
      } else {
        throw const ServerFailure('Failed to fetch tasks');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['detail'] ?? 'Server Error');
    }
  }

  @override
  Future<List<TaskModel>> getTasksByProject(int projectId) async {
    try {
      // Assuming backend endpoint /projects/{id}/tasks or filter
      final response = await client.get('/projects/$projectId/tasks');
      if (response.statusCode == 200) {
        return (response.data as List)
            .map((e) => TaskModel.fromJson(e))
            .toList();
      } else {
        throw const ServerFailure('Failed to fetch project tasks');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw ServerFailure(e.response?.data['detail'] ?? 'Server Error');
    }
  }

  @override
  Future<TaskModel> createTask(Task task) async {
    try {
      final taskModel = TaskModel.fromTask(task);
      final response = await client.post('/tasks/', data: taskModel.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return TaskModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to create task');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['detail'] ?? 'Server Error');
    }
  }

  @override
  Future<TaskModel> updateStatus(int taskId, TaskStatus status) async {
    try {
      final response = await client.patch(
        '/tasks/$taskId',
        data: {'status': TaskModel.statusToString(status)},
      );
      if (response.statusCode == 200) {
        return TaskModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to update status');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['detail'] ?? 'Server Error');
    }
  }

  @override
  Future<void> submitTask(
    int taskId,
    double timeSpent,
    String? filePath,
  ) async {
    try {
      if (filePath == null || filePath.isEmpty) {
        throw const ServerFailure('Please attach a solution zip file.');
      }
      final formData = FormData.fromMap({'hours': timeSpent});
      formData.files.add(
        MapEntry('file', await MultipartFile.fromFile(filePath)),
      );
      final response = await client.post(
        '/tasks/$taskId/submit',
        data: formData,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }
      throw const ServerFailure('Failed to submit task');
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['detail'] ?? 'Server Error');
    }
  }
}
