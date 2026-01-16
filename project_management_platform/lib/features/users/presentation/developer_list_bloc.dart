import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../auth/domain/user.dart';
import '../../auth/domain/get_all_users_usecase.dart';

abstract class DeveloperListEvent extends Equatable {
  const DeveloperListEvent();
  @override
  List<Object> get props => [];
}

class LoadDevelopers extends DeveloperListEvent {}

abstract class DeveloperListState extends Equatable {
  const DeveloperListState();
  @override
  List<Object> get props => [];
}

class DeveloperListInitial extends DeveloperListState {}

class DeveloperListLoading extends DeveloperListState {}

class DeveloperListLoaded extends DeveloperListState {
  final List<User> developers;
  const DeveloperListLoaded(this.developers);
  @override
  List<Object> get props => [developers];
}

class DeveloperListError extends DeveloperListState {
  final String message;
  const DeveloperListError(this.message);
  @override
  List<Object> get props => [message];
}

@injectable
class DeveloperListBloc extends Bloc<DeveloperListEvent, DeveloperListState> {
  final GetAllUsersUseCase getAllUsers;

  DeveloperListBloc(this.getAllUsers) : super(DeveloperListInitial()) {
    on<LoadDevelopers>((event, emit) async {
      emit(DeveloperListLoading());
      final result = await getAllUsers();
      result.fold(
        (failure) => emit(DeveloperListError(failure.message)),
        (developers) => emit(DeveloperListLoaded(developers)),
      );
    });
  }
}
