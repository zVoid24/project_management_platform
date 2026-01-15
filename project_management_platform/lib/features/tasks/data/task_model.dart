import '../domain/task.dart';

class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.hourlyRate,
    required super.assigneeId,
    required super.projectId,
    required super.status,
    super.timeSpent,
  });

  factory TaskModel.fromTask(Task task) {
    return TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      hourlyRate: task.hourlyRate,
      assigneeId: task.assigneeId,
      projectId: task.projectId,
      status: task.status,
      timeSpent: task.timeSpent,
    );
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      hourlyRate: (json['hourly_rate'] as num).toDouble(),
      assigneeId: json['assignee_id'],
      projectId: json['project_id'],
      status: _mapStringToStatus(json['status']),
      timeSpent: (json['time_spent'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'hourly_rate': hourlyRate,
      'assignee_id': assigneeId,
      'project_id': projectId,
      'status': statusToString(status),
    };
  }

  static TaskStatus _mapStringToStatus(String status) {
    switch (status) {
      case 'todo':
      case 'TODO':
        return TaskStatus.todo;
      case 'in_progress':
      case 'IN_PROGRESS':
        return TaskStatus.inProgress;
      case 'submitted':
      case 'SUBMITTED':
        return TaskStatus.submitted;
      case 'paid':
      case 'PAID':
        return TaskStatus.paid;
      default:
        return TaskStatus.todo;
    }
  }

  static String statusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'todo';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.submitted:
        return 'submitted';
      case TaskStatus.paid:
        return 'paid';
    }
  }
}
