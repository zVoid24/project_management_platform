import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../projects/presentation/project_bloc.dart';
import '../../../injection_container.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProjectBloc>(),
      child: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectLoaded) {
            // Success - technically LoadProjects is emitted after creation
            Navigator.of(context).pop();
          } else if (state is ProjectError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('Create Project')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: state is ProjectLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                context.read<ProjectBloc>().add(
                                  CreateProjectRequested(
                                    _titleController.text,
                                    _descController.text,
                                  ),
                                );
                              }
                            },
                      child: state is ProjectLoading
                          ? const CircularProgressIndicator()
                          : const Text('Create'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
