import 'package:equatable/equatable.dart';

class Project extends Equatable {
  final int id;
  final String title;
  final String description;
  final int ownerId;
  final int taskCount;

  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    this.taskCount = 0,
  });

  @override
  List<Object> get props => [id, title, description, ownerId, taskCount];
}
