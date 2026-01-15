// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import 'core/api/network_module.dart' as _i772;
import 'features/auth/data/auth_remote_data_source.dart' as _i516;
import 'features/auth/data/auth_repository_impl.dart' as _i581;
import 'features/auth/domain/auth_repository.dart' as _i260;
import 'features/auth/domain/login_usecase.dart' as _i42;
import 'features/auth/presentation/auth_bloc.dart' as _i770;
import 'features/projects/data/project_remote_data_source.dart' as _i961;
import 'features/projects/data/project_repository_impl.dart' as _i490;
import 'features/projects/domain/project_repository.dart' as _i595;
import 'features/projects/domain/project_usecases.dart' as _i856;
import 'features/projects/presentation/project_bloc.dart' as _i958;
import 'features/tasks/data/task_remote_data_source.dart' as _i587;
import 'features/tasks/data/task_repository_impl.dart' as _i384;
import 'features/tasks/domain/task_repository.dart' as _i651;
import 'features/tasks/domain/task_usecases.dart' as _i793;
import 'features/tasks/presentation/task_bloc.dart' as _i989;
import 'features/users/data/user_remote_data_source.dart' as _i273;
import 'features/users/data/user_repository_impl.dart' as _i902;
import 'features/users/domain/get_developers_usecase.dart' as _i340;
import 'features/users/domain/user_repository.dart' as _i625;
import 'features/users/presentation/developer_list_bloc.dart' as _i1;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => coreModule.prefs,
      preResolve: true,
    );
    gh.lazySingleton<_i361.Dio>(() => coreModule.dio);
    gh.lazySingleton<_i587.TaskRemoteDataSource>(
      () => _i587.TaskRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i273.UserRemoteDataSource>(
      () => _i273.UserRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i651.TaskRepository>(
      () => _i384.TaskRepositoryImpl(gh<_i587.TaskRemoteDataSource>()),
    );
    gh.lazySingleton<_i516.AuthRemoteDataSource>(
      () => _i516.AuthRemoteDataSourceImpl(
        client: gh<_i361.Dio>(),
        prefs: gh<_i460.SharedPreferences>(),
      ),
    );
    gh.lazySingleton<_i625.UserRepository>(
      () => _i902.UserRepositoryImpl(gh<_i273.UserRemoteDataSource>()),
    );
    gh.lazySingleton<_i961.ProjectRemoteDataSource>(
      () => _i961.ProjectRemoteDataSourceImpl(client: gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i793.GetAssignedTasksUseCase>(
      () => _i793.GetAssignedTasksUseCase(gh<_i651.TaskRepository>()),
    );
    gh.lazySingleton<_i793.GetTasksByProjectUseCase>(
      () => _i793.GetTasksByProjectUseCase(gh<_i651.TaskRepository>()),
    );
    gh.lazySingleton<_i793.CreateTaskUseCase>(
      () => _i793.CreateTaskUseCase(gh<_i651.TaskRepository>()),
    );
    gh.lazySingleton<_i793.SubmitTaskUseCase>(
      () => _i793.SubmitTaskUseCase(gh<_i651.TaskRepository>()),
    );
    gh.factory<_i989.TaskBloc>(
      () => _i989.TaskBloc(
        gh<_i793.GetAssignedTasksUseCase>(),
        gh<_i793.GetTasksByProjectUseCase>(),
        gh<_i793.CreateTaskUseCase>(),
        gh<_i793.SubmitTaskUseCase>(),
      ),
    );
    gh.lazySingleton<_i340.GetDevelopersUseCase>(
      () => _i340.GetDevelopersUseCase(gh<_i625.UserRepository>()),
    );
    gh.lazySingleton<_i260.AuthRepository>(
      () => _i581.AuthRepositoryImpl(gh<_i516.AuthRemoteDataSource>()),
    );
    gh.factory<_i1.DeveloperListBloc>(
      () => _i1.DeveloperListBloc(gh<_i340.GetDevelopersUseCase>()),
    );
    gh.lazySingleton<_i595.ProjectRepository>(
      () => _i490.ProjectRepositoryImpl(gh<_i961.ProjectRemoteDataSource>()),
    );
    gh.lazySingleton<_i42.LoginUseCase>(
      () => _i42.LoginUseCase(gh<_i260.AuthRepository>()),
    );
    gh.lazySingleton<_i856.GetProjectsUseCase>(
      () => _i856.GetProjectsUseCase(gh<_i595.ProjectRepository>()),
    );
    gh.lazySingleton<_i856.CreateProjectUseCase>(
      () => _i856.CreateProjectUseCase(gh<_i595.ProjectRepository>()),
    );
    gh.factory<_i770.AuthBloc>(() => _i770.AuthBloc(gh<_i42.LoginUseCase>()));
    gh.factory<_i958.ProjectBloc>(
      () => _i958.ProjectBloc(
        gh<_i856.GetProjectsUseCase>(),
        gh<_i856.CreateProjectUseCase>(),
      ),
    );
    return this;
  }
}

class _$CoreModule extends _i772.CoreModule {}
