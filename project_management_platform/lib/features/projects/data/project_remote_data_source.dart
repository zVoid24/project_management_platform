import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import 'project_model.dart';

abstract class ProjectRemoteDataSource {
  Future<List<ProjectModel>> getProjects();
  Future<ProjectModel> createProject(String title, String description);
}

@LazySingleton(as: ProjectRemoteDataSource)
class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final Dio client;

  ProjectRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await client.get('/projects/');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => ProjectModel.fromJson(e)).toList();
      } else {
        throw const ServerFailure('Failed to fetch projects');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['detail'] ?? 'Server Error');
    }
  }

  @override
  Future<ProjectModel> createProject(String title, String description) async {
    try {
      final response = await client.post(
        '/projects/',
        data: {'title': title, 'description': description},
      );

      if (response.statusCode == 200) {
        return ProjectModel.fromJson(response.data);
      } else {
        throw const ServerFailure('Failed to create project');
      }
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['detail'] ?? 'Server Error');
    }
  }
}
