import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../auth/presentation/auth_bloc.dart';
import '../../stats/presentation/admin_stats_bloc.dart';
import '../../../core/widgets/user_profile_header.dart';
import '../../../injection_container.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => sl<AdminStatsBloc>()..add(LoadAdminStats()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            context.go('/');
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Admin Dashboard')),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: BlocConsumer<AdminStatsBloc, AdminStatsState>(
              listener: (context, state) {
                if (state is AdminStatsError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                if (state is AdminStatsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AdminStatsLoaded) {
                  final stats = state.stats;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserProfileHeader(
                        onLogout: () {
                          context.read<AuthBloc>().add(LogoutRequested());
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Platform overview',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Live stats across projects, tasks, and payments.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.1,
                          children: [
                            _StatCard(
                              title: 'Total Projects',
                              value: '${stats.totalProjects}',
                            ),
                            _StatCard(
                              title: 'Total Tasks',
                              value: '${stats.totalTasks}',
                            ),
                            _StatCard(
                              title: 'Completed Tasks',
                              value: '${stats.completedTasks}',
                            ),
                            _StatCard(
                              title: 'Payments Received',
                              value:
                                  '\$${stats.totalPaymentsReceived.toStringAsFixed(0)}',
                            ),
                            _StatCard(
                              title: 'Pending Payments',
                              value: '${stats.pendingPayments}',
                            ),
                            _StatCard(
                              title: 'Developer Hours',
                              value:
                                  stats.totalDeveloperHours.toStringAsFixed(1),
                            ),
                            _StatCard(
                              title: 'Revenue Generated',
                              value:
                                  '\$${stats.revenueGenerated.toStringAsFixed(0)}',
                            ),
                            _StatCard(
                              title: 'Buyers',
                              value: '${stats.totalBuyers}',
                            ),
                            _StatCard(
                              title: 'Developers',
                              value: '${stats.totalDevelopers}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const Center(child: Text('No stats loaded'));
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
