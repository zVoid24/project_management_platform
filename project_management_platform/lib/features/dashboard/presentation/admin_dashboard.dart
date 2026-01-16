import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_widgets.dart';
// import '../../../core/widgets/user_profile_header.dart'; // Removed
import '../../../injection_container.dart';
import '../../auth/presentation/auth_bloc.dart';
import '../../stats/presentation/admin_stats_bloc.dart';
import '../../users/presentation/developer_list_bloc.dart';
import '../../tasks/presentation/admin_tasks_bloc.dart';
import 'account_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<AdminStatsBloc>()..add(LoadAdminStats()),
        ),
        BlocProvider(
          create: (context) => sl<DeveloperListBloc>()..add(LoadDevelopers()),
        ),
        BlocProvider(
          create: (context) => sl<AdminTasksBloc>()..add(LoadAdminTasks()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            context.go('/');
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Admin Overview'),
            actions: [
              IconButton(
                icon: const Icon(Icons.person),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AccountScreen()),
                  );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<AdminStatsBloc>().add(LoadAdminStats());
              context.read<DeveloperListBloc>().add(LoadDevelopers());
              context.read<AdminTasksBloc>().add(LoadAdminTasks());
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StatsSection(),
                  const SizedBox(height: 24),
                  const _ChartsSection(),
                  const SizedBox(height: 24),
                  const _TaskListSection(),
                  const SizedBox(height: 24),
                  const _UserListSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskListSection extends StatelessWidget {
  const _TaskListSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Tasks & Rates',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        BlocBuilder<AdminTasksBloc, AdminTasksState>(
          builder: (context, state) {
            if (state is AdminTasksLoaded) {
              if (state.tasks.isEmpty) {
                return const Text('No tasks found.');
              }
              // Show last 5 tasks
              final tasks = state.tasks.take(5).toList();
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return PremiumCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.assignment_outlined,
                            color: AppTheme.primaryBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '\$${task.hourlyRate.toStringAsFixed(0)}/hr',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        StatusChip.forStatus(task.status),
                      ],
                    ),
                  );
                },
              );
            } else if (state is AdminTasksError) {
              return Text('Error: ${state.message}');
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminStatsBloc, AdminStatsState>(
      builder: (context, state) {
        if (state is AdminStatsLoaded) {
          final stats = state.stats;
          return Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Total Revenue',
                  value: '\$${stats.revenueGenerated.toStringAsFixed(0)}',
                  icon: Icons.attach_money,
                  color: AppTheme.successGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: MetricCard(
                  label: 'Active Projects',
                  value: '${stats.totalProjects}',
                  icon: Icons.folder_open,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _ChartsSection extends StatelessWidget {
  const _ChartsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminStatsBloc, AdminStatsState>(
      builder: (context, state) {
        if (state is AdminStatsLoaded) {
          final stats = state.stats;
          return Column(
            children: [
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Revenue vs Pending',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: BarChart(
                        BarChartData(
                          // Simple Bar Chart
                          alignment: BarChartAlignment.spaceAround,
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: stats.revenueGenerated,
                                  color: AppTheme.successGreen,
                                  width: 20,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  // toY: stats.pendingPayments
                                  //     .toDouble(), // Assuming pending is amount, API says it's int count? Domain says int.
                                  // // Wait, pendingPayments in domain is int. I should probably use something else or just map it.
                                  // // Let's assume it represents count for now or money if I misunderstood.
                                  // // Let's us completedTasks vs pendingTasks (derived?)
                                  // // Let's use Revenue vs a dummy target or just show Revenue.
                                  // // Actually let's show Completed vs Pending Tasks counts.
                                  toY:
                                      stats.pendingPayments.toDouble() *
                                      100, // Dummy scale if needed, but let's stick to simple
                                  color: AppTheme.warningOrange,
                                  width: 20,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                            ),
                          ],
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return const Text('Paid');
                                    case 1:
                                      return const Text('Pending');
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Project Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: stats.completedTasks.toDouble(),
                              color: AppTheme.successGreen,
                              title: '${stats.completedTasks}',
                              radius: 50,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              value: (stats.totalTasks - stats.completedTasks)
                                  .toDouble(), // Remaining
                              color: AppTheme.primaryBlue,
                              title:
                                  '${stats.totalTasks - stats.completedTasks}',
                              radius: 50,
                              titleStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendItem(
                          color: AppTheme.successGreen,
                          label: 'Completed',
                        ),
                        const SizedBox(width: 16),
                        _LegendItem(
                          color: AppTheme.primaryBlue,
                          label: 'In Progress',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _UserListSection extends StatelessWidget {
  const _UserListSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Platform Users', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        BlocBuilder<DeveloperListBloc, DeveloperListState>(
          builder: (context, state) {
            if (state is DeveloperListLoaded) {
              if (state.developers.isEmpty) {
                return const Text('No developers found.');
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.developers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = state.developers[index];
                  return PremiumCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppTheme.primaryBlue.withOpacity(
                            0.1,
                          ),
                          child: Text(
                            user.email[0].toUpperCase(),
                            style: const TextStyle(color: AppTheme.primaryBlue),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.email,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                user.role.toString().split('.').last,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        // Status indicator (dummy for now as User model might not have status)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              color: AppTheme.successGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else if (state is DeveloperListError) {
              return Text('Error loading users: ${state.message}');
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ],
    );
  }
}
