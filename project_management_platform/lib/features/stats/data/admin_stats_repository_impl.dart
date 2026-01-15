import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../domain/admin_stats.dart';
import '../domain/admin_stats_repository.dart';
import 'admin_stats_remote_data_source.dart';

@LazySingleton(as: AdminStatsRepository)
class AdminStatsRepositoryImpl implements AdminStatsRepository {
  final AdminStatsRemoteDataSource remoteDataSource;
  AdminStatsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, AdminStats>> getAdminStats() async {
    try {
      final result = await remoteDataSource.getAdminStats();
      return Right(
        AdminStats(
          totalProjects: result.totalProjects,
          totalTasks: result.totalTasks,
          completedTasks: result.completedTasks,
          totalPaymentsReceived: result.totalPaymentsReceived,
          pendingPayments: result.pendingPayments,
          totalDeveloperHours: result.totalDeveloperHours,
          revenueGenerated: result.revenueGenerated,
          totalBuyers: result.totalBuyers,
          totalDevelopers: result.totalDevelopers,
        ),
      );
    } on Failure catch (e) {
      return Left(e);
    } catch (_) {
      return const Left(ServerFailure('Unexpected Error'));
    }
  }
}
