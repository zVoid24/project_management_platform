import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../auth/domain/user.dart';
import '../../auth/domain/get_all_users_usecase.dart';

abstract class UsersState extends Equatable {
  const UsersState();
  @override
  List<Object> get props => [];
}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<User> users;
  const UsersLoaded(this.users);
  @override
  List<Object> get props => [users];
}

class UsersError extends UsersState {
  final String message;
  const UsersError(this.message);
  @override
  List<Object> get props => [message];
}

@injectable
class UsersCubit extends Cubit<UsersState> {
  final GetAllUsersUseCase getAllUsers;

  UsersCubit(this.getAllUsers) : super(UsersInitial());

  Future<void> loadUsers() async {
    emit(UsersLoading());
    final result = await getAllUsers();
    result.fold(
      (failure) => emit(UsersError(failure.message)),
      (users) => emit(UsersLoaded(users)),
    );
  }
}
