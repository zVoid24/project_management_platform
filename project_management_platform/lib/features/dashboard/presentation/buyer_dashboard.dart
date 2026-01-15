import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../projects/presentation/project_bloc.dart';
import '../../projects/presentation/create_project_screen.dart';
import '../../projects/presentation/project_details_screen.dart';
import '../../../injection_container.dart';

class BuyerDashboard extends StatelessWidget {
  const BuyerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Projects')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(
                MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
              )
              .then((_) {
                if (context.mounted) {
                  context.read<ProjectBloc>().add(LoadProjects());
                }
              });
        },
        child: const Icon(Icons.add),
      ),
      body: BlocProvider(
        create: (context) => sl<ProjectBloc>()..add(LoadProjects()),
        child: BlocConsumer<ProjectBloc, ProjectState>(
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
            } else if (state is ProjectLoaded) {
              if (state.projects.isEmpty) {
                return const Center(child: Text('No projects yet'));
              }
              return ListView.builder(
                itemCount: state.projects.length,
                itemBuilder: (context, index) {
                  final project = state.projects[index];
                  return ListTile(
                    title: Text(project.title),
                    subtitle: Text(project.description),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ProjectDetailsScreen(project: project),
                        ),
                      );
                    },
                  );
                },
              );
            }
            return const Center(child: Text('No projects loaded'));
          },
        ),
      ),
    );
  }
}
