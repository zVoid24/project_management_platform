import 'package:equatable/equatable.dart';

enum TaskStatus { todo, inProgress, submitted, paid }

extension TaskStatusLabel on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'Todo';
      case TaskStatus.inProgress:
        return 'In progress';
      case TaskStatus.submitted:
        return 'Submitted';
      case TaskStatus.paid:
        return 'Paid';
    }
  }
}

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

  Task copyWith({
    int? id,
    String? title,
    String? description,
    double? hourlyRate,
    int? assigneeId,
    int? projectId,
    TaskStatus? status,
    double? timeSpent,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      assigneeId: assigneeId ?? this.assigneeId,
      projectId: projectId ?? this.projectId,
      status: status ?? this.status,
      timeSpent: timeSpent ?? this.timeSpent,
    );
  }

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
