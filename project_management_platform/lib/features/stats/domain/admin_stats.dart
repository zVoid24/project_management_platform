import 'package:equatable/equatable.dart';

class AdminStats extends Equatable {
  final int totalProjects;
  final int totalTasks;
  final int completedTasks;
  final double totalPaymentsReceived;
  final int pendingPayments;
  final double totalDeveloperHours;
  final double revenueGenerated;
  final int totalBuyers;
  final int totalDevelopers;

  const AdminStats({
    required this.totalProjects,
    required this.totalTasks,
    required this.completedTasks,
    required this.totalPaymentsReceived,
    required this.pendingPayments,
    required this.totalDeveloperHours,
    required this.revenueGenerated,
    required this.totalBuyers,
    required this.totalDevelopers,
  });

  @override
  List<Object> get props => [
        totalProjects,
        totalTasks,
        completedTasks,
        totalPaymentsReceived,
        pendingPayments,
        totalDeveloperHours,
        revenueGenerated,
        totalBuyers,
        totalDevelopers,
      ];
}
