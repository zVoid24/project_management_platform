import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../tasks/presentation/task_bloc.dart';
import '../../tasks/domain/task.dart';
import '../../../injection_container.dart';

class DeveloperDashboard extends StatelessWidget {
  const DeveloperDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: BlocProvider(
        create: (context) => sl<TaskBloc>()..add(LoadAssignedTasks()),
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
                return const Center(child: Text('No tasks assigned'));
              return ListView.builder(
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(task.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task.description),
                          const SizedBox(height: 4),
                          Chip(label: Text(task.status.name.toUpperCase())),
                        ],
                      ),
                      trailing: Text('\$${task.hourlyRate}/hr'),
                      onTap: () {
                        // TODO: Navigate to Task Details for submission
                      },
                    ),
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
