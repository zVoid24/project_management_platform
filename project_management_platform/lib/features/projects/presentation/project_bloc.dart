import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/project.dart';
import '../domain/project_usecases.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();
  @override
  List<Object> get props => [];
}

class LoadProjects extends ProjectEvent {}

class CreateProjectRequested extends ProjectEvent {
  final String title;
  final String description;
  const CreateProjectRequested(this.title, this.description);
  @override
  List<Object> get props => [title, description];
}

abstract class ProjectState extends Equatable {
  const ProjectState();
  @override
  List<Object> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectLoaded extends ProjectState {
  final List<Project> projects;
  const ProjectLoaded(this.projects);
  @override
  List<Object> get props => [projects];
}

class ProjectError extends ProjectState {
  final String message;
  const ProjectError(this.message);
  @override
  List<Object> get props => [message];
}

@injectable
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final GetProjectsUseCase getProjects;
  final CreateProjectUseCase createProject;

  ProjectBloc(this.getProjects, this.createProject) : super(ProjectInitial()) {
    on<LoadProjects>((event, emit) async {
      emit(ProjectLoading());
      final result = await getProjects();
      result.fold(
        (failure) => emit(ProjectError(failure.message)),
        (projects) => emit(ProjectLoaded(projects)),
      );
    });

    on<CreateProjectRequested>((event, emit) async {
      emit(ProjectLoading());
      final result = await createProject(event.title, event.description);
      result.fold((failure) => emit(ProjectError(failure.message)), (project) {
        // Reload projects after creation
        add(LoadProjects());
      });
    });
  }
}
