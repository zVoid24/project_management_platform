import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../tasks/presentation/task_bloc.dart';
import '../../tasks/domain/task.dart';
import '../../tasks/presentation/task_details_screen.dart';
import '../../auth/presentation/auth_bloc.dart';
import '../../../core/widgets/user_profile_header.dart';
import '../../../injection_container.dart';

class DeveloperDashboard extends StatelessWidget {
  const DeveloperDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocProvider(
      create: (context) => sl<TaskBloc>()..add(LoadAssignedTasks()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            context.go('/');
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Developer Dashboard')),
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
              } else if (state is TaskLoaded) {
                final itemCount =
                    state.tasks.isEmpty ? 2 : state.tasks.length + 1;
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  itemCount: itemCount,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return UserProfileHeader(
                        onLogout: () {
                          context.read<AuthBloc>().add(LogoutRequested());
                        },
                      );
                    }
                    if (state.tasks.isEmpty) {
                      return const Center(child: Text('No tasks assigned'));
                    }
                    final task = state.tasks[index - 1];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    task.title,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    task.status.label,
                                    style:
                                        theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              task.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 16,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '\$${task.hourlyRate.toStringAsFixed(0)}/hr',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () async {
                                    final refreshed =
                                        await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => TaskDetailsScreen(
                                          task: task,
                                          mode: TaskDetailsMode.developer,
                                        ),
                                      ),
                                    );
                                    if (refreshed == true &&
                                        context.mounted) {
                                      context
                                          .read<TaskBloc>()
                                          .add(LoadAssignedTasks());
                                    }
                                  },
                                  child: const Text('View details'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return const Center(child: Text('No tasks'));
            },
          ),
        ),
      ),
    );
  }
}
