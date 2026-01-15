import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../users/presentation/developer_list_bloc.dart';
import '../presentation/task_bloc.dart';
import '../domain/task.dart';
import '../../../injection_container.dart';
import '../../auth/domain/user.dart';

class CreateTaskScreen extends StatefulWidget {
  final int projectId;
  const CreateTaskScreen({super.key, required this.projectId});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _rateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  User? _selectedDeveloper;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<DeveloperListBloc>()..add(LoadDevelopers()),
        ),
        BlocProvider(create: (context) => sl<TaskBloc>()),
      ],
      child: Scaffold(
        appBar: AppBar(title: const Text('New Task')),
        body: BlocListener<TaskBloc, TaskState>(
          listener: (context, state) {
            if (state is TaskOperationSuccess) {
              Navigator.of(context).pop(true);
            } else if (state is TaskError) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Add a new task',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set expectations and assign it to the right developer.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Task Title'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _rateController,
                      decoration: const InputDecoration(
                        labelText: 'Hourly Rate (\$)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<DeveloperListBloc, DeveloperListState>(
                      builder: (context, state) {
                        if (state is DeveloperListLoading) {
                          return const LinearProgressIndicator();
                        } else if (state is DeveloperListLoaded) {
                          return DropdownButtonFormField<User>(
                            decoration: const InputDecoration(
                              labelText: 'Assign Developer',
                            ),
                            items: state.developers.map((user) {
                              return DropdownMenuItem(
                                value: user,
                                child: Text(user.email),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _selectedDeveloper = val);
                            },
                            validator: (v) => v == null ? 'Required' : null,
                          );
                        } else if (state is DeveloperListError) {
                          return Text(
                            'Error loading developers: ${state.message}',
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    const SizedBox(height: 24),
                    Builder(
                      builder: (ctx) {
                        return FilledButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final task = Task(
                                id: 0, // Ignored by create
                                title: _titleController.text,
                                description: _descController.text,
                                hourlyRate: double.parse(_rateController.text),
                                assigneeId: _selectedDeveloper!.id,
                                projectId: widget.projectId,
                                status: TaskStatus.todo,
                              );
                              ctx
                                  .read<TaskBloc>()
                                  .add(CreateTaskRequested(task));
                            }
                          },
                          child: const Text('Create Task'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
