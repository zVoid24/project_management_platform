import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import 'admin_stats.dart';
import 'admin_stats_repository.dart';

@lazySingleton
class GetAdminStatsUseCase {
  final AdminStatsRepository repository;
  GetAdminStatsUseCase(this.repository);

  Future<Either<Failure, AdminStats>> call() => repository.getAdminStats();
}
