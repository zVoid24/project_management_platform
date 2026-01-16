import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../tasks/presentation/task_bloc.dart';
import '../../tasks/presentation/create_task_modal.dart';
import '../../tasks/presentation/task_details_screen.dart';
import '../../projects/domain/project.dart';
import '../../tasks/domain/task.dart';
import '../../auth/presentation/auth_bloc.dart';
// import '../../../core/widgets/user_profile_header.dart'; // Removed
import '../../../core/widgets/custom_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../../../injection_container.dart';
import 'package:go_router/go_router.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final Project project;
  const ProjectDetailsScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TaskBloc>()..add(LoadProjectTasks(project.id)),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            context.go('/');
          }
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              appBar: AppBar(title: const Text('Project Details')),
              floatingActionButton: FloatingActionButton(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (modalContext) => CreateTaskModal(
                      onCreate: (title, description, assigneeId, hourlyRate) {
                        context.read<TaskBloc>().add(
                          CreateTaskRequested(
                            Task(
                              id: 0,
                              title: title,
                              description: description,
                              hourlyRate: hourlyRate,
                              assigneeId: assigneeId,
                              projectId: project.id,
                              status: TaskStatus.todo,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                child: const Icon(Icons.add_task),
              ),
              body: BlocConsumer<TaskBloc, TaskState>(
                listener: (context, state) {
                  if (state is TaskError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  } else if (state is TaskOperationSuccess) {
                    context.read<TaskBloc>().add(LoadProjectTasks(project.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Task created successfully!'),
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is TaskLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TaskLoaded) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<TaskBloc>().add(
                          LoadProjectTasks(project.id),
                        );
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
                        itemCount: state.tasks.isEmpty
                            ? 1
                            : state.tasks.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // Project Info Card
                            return PremiumCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project.title,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    project.description,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.label_outline,
                                        size: 16,
                                        color: AppTheme.textGrey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'ID: ${project.id}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }

                          if (state.tasks.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 40),
                              child: Center(
                                child: Text('No tasks created yet.'),
                              ),
                            );
                          }

                          final taskIndex = index - 1;
                          final task = state.tasks[taskIndex];

                          return PremiumCard(
                            onTap: () async {
                              final refreshed = await Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (_) => TaskDetailsScreen(
                                        task: task,
                                        mode: TaskDetailsMode.buyer,
                                      ),
                                    ),
                                  );
                              if (refreshed == true && context.mounted) {
                                context.read<TaskBloc>().add(
                                  LoadProjectTasks(project.id),
                                );
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        task.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    StatusChip.forStatus(task.status),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(
                                      '\$${task.hourlyRate}/hr',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.darkNavy,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (task.assigneeId != 0)
                                      Chip(
                                        avatar: const Icon(
                                          Icons.person,
                                          size: 14,
                                        ),
                                        label: Text(
                                          'Dev ${task.assigneeId}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        visualDensity: VisualDensity.compact,
                                        backgroundColor: AppTheme.surfaceGrey,
                                        side: BorderSide.none,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }
                  return const Center(child: Text('No tasks loaded'));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
