import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../projects/presentation/project_bloc.dart';
import '../../projects/presentation/create_project_screen.dart';
import '../../projects/presentation/project_details_screen.dart';
import '../../auth/presentation/auth_bloc.dart';
import '../../../core/widgets/custom_widgets.dart';
import 'account_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../injection_container.dart';

class BuyerDashboard extends StatelessWidget {
  const BuyerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProjectBloc>()..add(LoadProjects()),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            context.go('/');
          }
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              backgroundColor: AppTheme.surfaceGrey,
              floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CreateProjectScreen(),
                    ),
                  );
                  if (result == true && context.mounted) {
                    context.read<ProjectBloc>().add(LoadProjects());
                  }
                },
                child: const Icon(Icons.add),
              ),
              body: BlocConsumer<ProjectBloc, ProjectState>(
                listener: (context, state) {
                  if (state is ProjectError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  if (state is ProjectLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final projects = (state is ProjectLoaded)
                      ? state.projects
                      : [];

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ProjectBloc>().add(LoadProjects());
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Dashboard',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.headlineMedium,
                                        ),
                                        Text(
                                          'Welcome back',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                    BlocBuilder<AuthBloc, AuthState>(
                                      builder: (context, authState) {
                                        String initials = 'BY';
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
                                                    names[0].length >= 2
                                                        ? 2
                                                        : 1,
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
                                            backgroundColor: AppTheme
                                                .primaryBlue
                                                .withOpacity(0.1),
                                            child: Text(
                                              initials,
                                              style: const TextStyle(
                                                color: AppTheme.primaryBlue,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                Row(
                                  children: [
                                    Text(
                                      'Projects',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBlue.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${projects.length}',
                                        style: const TextStyle(
                                          color: AppTheme.primaryBlue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                        if (projects.isEmpty)
                          SliverFillRemaining(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.folder_open,
                                    size: 60,
                                    color: AppTheme.textGrey.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No projects found',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                  Text(
                                    'Create one to get started',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16,
                                    crossAxisSpacing: 16,
                                    childAspectRatio: 0.85,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final project = projects[index];
                                return MakaryaProjectCard(
                                  title: project.title,
                                  taskCount:
                                      0, // Need to implement task count later
                                  onTap: () async {
                                    final result = await Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                ProjectDetailsScreen(
                                                  project: project,
                                                ),
                                          ),
                                        );
                                    if (context.mounted) {
                                      context.read<ProjectBloc>().add(
                                        LoadProjects(),
                                      );
                                    }
                                  },
                                );
                              }, childCount: projects.length),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
