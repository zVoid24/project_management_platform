import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../domain/admin_stats.dart';
import '../domain/get_admin_stats_usecase.dart';

abstract class AdminStatsEvent extends Equatable {
  const AdminStatsEvent();
  @override
  List<Object> get props => [];
}

class LoadAdminStats extends AdminStatsEvent {}

abstract class AdminStatsState extends Equatable {
  const AdminStatsState();
  @override
  List<Object> get props => [];
}

class AdminStatsInitial extends AdminStatsState {}

class AdminStatsLoading extends AdminStatsState {}

class AdminStatsLoaded extends AdminStatsState {
  final AdminStats stats;
  const AdminStatsLoaded(this.stats);
  @override
  List<Object> get props => [stats];
}

class AdminStatsError extends AdminStatsState {
  final String message;
  const AdminStatsError(this.message);
  @override
  List<Object> get props => [message];
}

@injectable
class AdminStatsBloc extends Bloc<AdminStatsEvent, AdminStatsState> {
  final GetAdminStatsUseCase getAdminStats;
  AdminStatsBloc(this.getAdminStats) : super(AdminStatsInitial()) {
    on<LoadAdminStats>((event, emit) async {
      emit(AdminStatsLoading());
      final result = await getAdminStats();
      result.fold(
        (failure) => emit(AdminStatsError(failure.message)),
        (stats) => emit(AdminStatsLoaded(stats)),
      );
    });
  }
}
