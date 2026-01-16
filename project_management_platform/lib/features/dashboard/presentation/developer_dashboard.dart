import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../tasks/presentation/task_bloc.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/presentation/task_details_screen.dart';
import '../../auth/presentation/auth_bloc.dart';
import '../../../core/widgets/custom_widgets.dart';
import 'account_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../injection_container.dart';

class DeveloperDashboard extends StatelessWidget {
  const DeveloperDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TaskBloc>()..add(LoadAssignedTasks()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            context.go('/');
          }
        },
        child: Scaffold(
          backgroundColor: AppTheme.surfaceGrey,
          body: BlocConsumer<TaskBloc, TaskState>(
            listener: (context, state) {
              if (state is TaskError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              if (state is TaskLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final tasks = (state is TaskLoaded) ? state.tasks : <Task>[];
              final todoTasks = tasks
                  .where((t) => t.status == TaskStatus.todo)
                  .toList();
              final otherTasks = tasks
                  .where((t) => t.status != TaskStatus.todo)
                  .toList();

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<TaskBloc>().add(LoadAssignedTasks());
                },
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Workspace',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                    ),
                                    Text(
                                      'Your assigned tasks',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),

                                BlocBuilder<AuthBloc, AuthState>(
                                  builder: (context, authState) {
                                    String initials = 'Dev';
                                    if (authState is AuthAuthenticated) {
                                      final user = authState.user;
                                      if (user.fullName != null &&
                                          user.fullName!.isNotEmpty) {
                                        final names = user.fullName!
                                            .trim()
                                            .split(' ');
                                        if (names.length >= 2) {
                                          initials =
                                              '${names[0][0]}${names[1][0]}'
                                                  .toUpperCase();
                                        } else if (names.isNotEmpty) {
                                          initials = names[0]
                                              .substring(
                                                0,
                                                names[0].length >= 2 ? 2 : 1,
                                              )
                                              .toUpperCase();
                                        }
                                      } else {
                                        initials = user.email
                                            .substring(0, 2)
                                            .toUpperCase();
                                      }
                                    }

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const AccountScreen(),
                                          ),
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 20,
                                        backgroundColor: AppTheme.primaryBlue
                                            .withOpacity(0.1),
                                        child: Text(
                                          initials,
                                          style: const TextStyle(
                                            color: AppTheme.primaryBlue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (tasks.isEmpty)
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 60,
                                color: AppTheme.textGrey.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'All caught up!',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      if (todoTasks.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Text(
                              'To Do',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: _buildTaskList(todoTasks),
                        ),
                      ],
                      if (otherTasks.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                            child: Text(
                              'In Progress & Completed',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                          sliver: _buildTaskList(otherTasks),
                        ),
                      ],
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final task = tasks[index];
        Color statusColor;
        String statusLabel;

        switch (task.status) {
          case TaskStatus.todo:
            statusColor = AppTheme.textGrey;
            statusLabel = 'To Do';
            break;
          case TaskStatus.inProgress:
            statusColor = AppTheme.primaryBlue;
            statusLabel = 'In Progress';
            break;
          case TaskStatus.submitted:
            statusColor = AppTheme.warningOrange;
            statusLabel = 'Under Review';
            break;
          case TaskStatus.paid:
            statusColor = AppTheme.successGreen;
            statusLabel = 'Completed';
            break;
        }

        return MakaryaTaskCard(
          title: task.title,
          subtitle: 'Project #${task.projectId} • \$${task.hourlyRate}/hr',
          statusLabel: statusLabel,
          statusColor: statusColor,
          isCompleted: task.status == TaskStatus.paid,
          onTap: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TaskDetailsScreen(
                  task: task,
                  mode: TaskDetailsMode.developer,
                ),
              ),
            );
            if (result == true && context.mounted) {
              context.read<TaskBloc>().add(LoadAssignedTasks());
            }
          },
        );
      }, childCount: tasks.length),
    );
  }
}
