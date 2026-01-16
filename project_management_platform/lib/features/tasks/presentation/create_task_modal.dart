import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../users/presentation/users_cubit.dart';
import '../../users/presentation/users_cubit.dart'; // Ensure correct import if needed, check steps.
// Actually, let's just use one import.
// Step 533 created it at /home/zvoid/Desktop/raco ai/project_management_platform/lib/features/users/presentation/users_cubit.dart
import '../../auth/domain/user.dart';
import '../../../injection_container.dart';

class CreateTaskModal extends StatefulWidget {
  final Function(
    String title,
    String description,
    int assigneeId,
    double hourlyRate,
  )
  onCreate;

  const CreateTaskModal({super.key, required this.onCreate});

  @override
  State<CreateTaskModal> createState() => _CreateTaskModalState();
}

class _CreateTaskModalState extends State<CreateTaskModal> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _rateController = TextEditingController(); // No default value
  int _assigneeId = 0; // 0 means unassigned

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<UsersCubit>()..loadUsers(),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Task',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkNavy,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: AppTheme.textGrey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Title',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkNavy,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g., Javanese Study...',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkNavy,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'e.g., Study Javanese language today...',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hourly Rate (\$)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkNavy,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _rateController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(hintText: 'e.g., 50'),
              ),

              const SizedBox(height: 16),
              const Text(
                'Assignee',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.darkNavy,
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<UsersCubit, UsersState>(
                builder: (context, state) {
                  if (state is UsersLoading) {
                    return const LinearProgressIndicator();
                  } else if (state is UsersLoaded) {
                    final developers = state.users
                        .where((u) => u.role == 'developer')
                        .toList();

                    if (developers.isEmpty) {
                      return const Text(
                        'No developers found',
                        style: TextStyle(color: AppTheme.textGrey),
                      );
                    }

                    return DropdownButtonFormField<int>(
                      isExpanded: true,
                      value: _assigneeId == 0 ? null : _assigneeId,
                      hint: const Text('Select a developer'),
                      items: developers.map((user) {
                        final displayName =
                            user.fullName != null && user.fullName!.isNotEmpty
                            ? '${user.fullName} (${user.email})'
                            : '${user.email} (Dev)';
                        return DropdownMenuItem<int>(
                          value: user.id,
                          child: Text(
                            displayName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _assigneeId = value ?? 0;
                        });
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    );
                  } else if (state is UsersError) {
                    return Text(
                      'Error loading users: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty) {
                    final rate = double.tryParse(_rateController.text) ?? 50.0;
                    widget.onCreate(
                      _titleController.text,
                      _descController.text,
                      _assigneeId,
                      rate,
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Create Task'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
