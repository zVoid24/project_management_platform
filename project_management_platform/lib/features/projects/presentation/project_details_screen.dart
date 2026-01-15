import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../tasks/presentation/task_bloc.dart';
import '../../tasks/presentation/create_task_screen.dart';
import '../../projects/domain/project.dart';
import '../../../injection_container.dart';

class ProjectDetailsScreen extends StatelessWidget {
  final Project project;
  const ProjectDetailsScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CreateTaskScreen(projectId: project.id),
            ),
          );
          if (result == true && context.mounted) {
            context.read<TaskBloc>().add(LoadProjectTasks(project.id));
          }
        },
        child: const Icon(Icons.add_task),
      ),
      body: BlocProvider(
        create: (context) => sl<TaskBloc>()..add(LoadProjectTasks(project.id)),
        child: BlocConsumer<TaskBloc, TaskState>(
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
              if (state.tasks.isEmpty)
                return const Center(child: Text('No tasks in this project'));
              return ListView.builder(
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  return ListTile(
                    title: Text(task.title),
                    subtitle: Text(
                      '${task.status.name} - \$${task.hourlyRate}/hr',
                    ),
                    trailing: Text(
                      task.assigneeId.toString(),
                    ), // Show assignee ID for now
                  );
                },
              );
            }
            return const Center(child: Text('No tasks'));
          },
        ),
      ),
    );
  }
}
