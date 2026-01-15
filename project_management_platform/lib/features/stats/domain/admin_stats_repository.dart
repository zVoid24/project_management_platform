import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import 'admin_stats.dart';

abstract class AdminStatsRepository {
  Future<Either<Failure, AdminStats>> getAdminStats();
}
