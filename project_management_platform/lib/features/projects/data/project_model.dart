import '../domain/project.dart';

class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.title,
    required super.description,
    required super.ownerId,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      ownerId: json['owner_id'],
    );
  }
}
