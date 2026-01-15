import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/task.dart';
import '../domain/task_usecases.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();
  @override
  List<Object?> get props => [];
}

class LoadAssignedTasks extends TaskEvent {}

class LoadProjectTasks extends TaskEvent {
  final int projectId;
  const LoadProjectTasks(this.projectId);
  @override
  List<Object> get props => [projectId];
}

class CreateTaskRequested extends TaskEvent {
  final Task task;
  const CreateTaskRequested(this.task);
  @override
  List<Object> get props => [task];
}

class UpdateTaskStatusRequested extends TaskEvent {
  final int taskId;
  final TaskStatus status;
  const UpdateTaskStatusRequested(this.taskId, this.status);
  @override
  List<Object> get props => [taskId, status];
}

class SubmitTaskRequested extends TaskEvent {
  final int taskId;
  final double timeSpent;
  final String? filePath;
  const SubmitTaskRequested(this.taskId, this.timeSpent, this.filePath);
  @override
  List<Object?> get props => [taskId, timeSpent, filePath];
}

class PayTaskRequested extends TaskEvent {
  final int taskId;
  const PayTaskRequested(this.taskId);
  @override
  List<Object> get props => [taskId];
}

class DownloadSolutionRequested extends TaskEvent {
  final int taskId;
  final String savePath;
  const DownloadSolutionRequested(this.taskId, this.savePath);
  @override
  List<Object> get props => [taskId, savePath];
}

abstract class TaskState extends Equatable {
  const TaskState();
  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;
  const TaskLoaded(this.tasks);
  @override
  List<Object> get props => [tasks];
}

class TaskOperationSuccess extends TaskState {
  // For create operations
  final Task task;
  const TaskOperationSuccess(this.task);
  @override
  List<Object> get props => [task];
}

class TaskSubmissionSuccess extends TaskState {
  const TaskSubmissionSuccess();
}

class TaskPaymentSuccess extends TaskState {
  final double amountPaid;
  const TaskPaymentSuccess(this.amountPaid);
  @override
  List<Object> get props => [amountPaid];
}

class TaskDownloadSuccess extends TaskState {
  const TaskDownloadSuccess();
}

class TaskError extends TaskState {
  final String message;
  const TaskError(this.message);
  @override
  List<Object> get props => [message];
}

@injectable
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetAssignedTasksUseCase getAssignedTasks;
  final GetTasksByProjectUseCase getTasksByProject;
  final CreateTaskUseCase createTask;
  final SubmitTaskUseCase submitTask;
  final UpdateTaskStatusUseCase updateTaskStatus;
  final PayForTaskUseCase payForTask;
  final DownloadSolutionUseCase downloadSolution;

  TaskBloc(
    this.getAssignedTasks,
    this.getTasksByProject,
    this.createTask,
    this.submitTask,
    this.updateTaskStatus,
    this.payForTask,
    this.downloadSolution,
  ) : super(TaskInitial()) {
    on<LoadAssignedTasks>((event, emit) async {
      emit(TaskLoading());
      final result = await getAssignedTasks();
      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (tasks) => emit(TaskLoaded(tasks)),
      );
    });

    on<LoadProjectTasks>((event, emit) async {
      emit(TaskLoading());
      final result = await getTasksByProject(event.projectId);
      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (tasks) => emit(TaskLoaded(tasks)),
      );
    });

    on<CreateTaskRequested>((event, emit) async {
      emit(TaskLoading());
      final result = await createTask(event.task);
      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (task) => emit(TaskOperationSuccess(task)),
      );
    });

    on<UpdateTaskStatusRequested>((event, emit) async {
      emit(TaskLoading());
      final result = await updateTaskStatus(event.taskId, event.status);
      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (task) => emit(TaskOperationSuccess(task)),
      );
    });

    on<SubmitTaskRequested>((event, emit) async {
      emit(TaskLoading());
      final result = await submitTask(
        event.taskId,
        event.timeSpent,
        event.filePath,
      );
      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (_) => emit(const TaskSubmissionSuccess()),
      );
    });

    on<PayTaskRequested>((event, emit) async {
      emit(TaskLoading());
      final result = await payForTask(event.taskId);
      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (amount) => emit(TaskPaymentSuccess(amount)),
      );
    });

    on<DownloadSolutionRequested>((event, emit) async {
      emit(TaskLoading());
      final result = await downloadSolution(event.taskId, event.savePath);
      result.fold(
        (failure) => emit(TaskError(failure.message)),
        (_) => emit(const TaskDownloadSuccess()),
      );
    });
  }
}
