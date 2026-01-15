class AdminStatsModel {
  final int totalProjects;
  final int totalTasks;
  final int completedTasks;
  final double totalPaymentsReceived;
  final int pendingPayments;
  final double totalDeveloperHours;
  final double revenueGenerated;
  final int totalBuyers;
  final int totalDevelopers;

  const AdminStatsModel({
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

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      totalProjects: json['total_projects'],
      totalTasks: json['total_tasks'],
      completedTasks: json['completed_tasks'],
      totalPaymentsReceived:
          (json['total_payments_received'] as num).toDouble(),
      pendingPayments: json['pending_payments'],
      totalDeveloperHours: (json['total_developer_hours'] as num).toDouble(),
      revenueGenerated: (json['revenue_generated'] as num).toDouble(),
      totalBuyers: json['total_buyers'],
      totalDevelopers: json['total_developers'],
    );
  }
}
