import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:project_management_platform/features/tasks/domain/get_all_tasks_usecase.dart';
import 'package:project_management_platform/features/tasks/domain/task.dart';

abstract class AdminTasksEvent extends Equatable {
  const AdminTasksEvent();
  @override
  List<Object> get props => [];
}

class LoadAdminTasks extends AdminTasksEvent {}

abstract class AdminTasksState extends Equatable {
  const AdminTasksState();
  @override
  List<Object> get props => [];
}

class AdminTasksInitial extends AdminTasksState {}

class AdminTasksLoading extends AdminTasksState {}

class AdminTasksLoaded extends AdminTasksState {
  final List<Task> tasks;
  const AdminTasksLoaded(this.tasks);
  @override
  List<Object> get props => [tasks];
}

class AdminTasksError extends AdminTasksState {
  final String message;
  const AdminTasksError(this.message);
  @override
  List<Object> get props => [message];
}

@injectable
class AdminTasksBloc extends Bloc<AdminTasksEvent, AdminTasksState> {
  final GetAllTasksUseCase getAllTasks;

  AdminTasksBloc(this.getAllTasks) : super(AdminTasksInitial()) {
    on<LoadAdminTasks>((event, emit) async {
      emit(AdminTasksLoading());
      final result = await getAllTasks();
      result.fold(
        (failure) => emit(AdminTasksError(failure.message)),
        (tasks) => emit(AdminTasksLoaded(tasks)),
      );
    });
  }
}
