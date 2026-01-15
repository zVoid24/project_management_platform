import 'package:equatable/equatable.dart';

enum TaskStatus { todo, inProgress, submitted, paid }

class Task extends Equatable {
  final int id;
  final String title;
  final String description;
  final double hourlyRate;
  final int assigneeId;
  final int projectId;
  final TaskStatus status;
  final double? timeSpent;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.hourlyRate,
    required this.assigneeId,
    required this.projectId,
    required this.status,
    this.timeSpent,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    hourlyRate,
    assigneeId,
    projectId,
    status,
    timeSpent,
  ];
}
