import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/task.dart';
import 'task_bloc.dart';
import '../../../injection_container.dart';

enum TaskDetailsMode { buyer, developer }

class TaskDetailsScreen extends StatefulWidget {
  final Task task;
  final TaskDetailsMode mode;
  const TaskDetailsScreen({
    super.key,
    required this.task,
    required this.mode,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late Task _task;
  final _hoursController = TextEditingController();
  String? _selectedFilePath;
  bool _shouldRefresh = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    if (_task.timeSpent != null) {
      _hoursController.text = _task.timeSpent!.toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  Future<void> _pickZipFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _selectedFilePath = result.files.single.path);
    }
  }

  Future<void> _downloadSolution(BuildContext context) async {
    final savePath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save solution zip',
      fileName: 'task_${_task.id}_solution.zip',
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (savePath == null) {
      return;
    }
    context
        .read<TaskBloc>()
        .add(DownloadSolutionRequested(_task.id, savePath));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBuyer = widget.mode == TaskDetailsMode.buyer;
    final amountDue = (_task.timeSpent ?? 0) * _task.hourlyRate;
    return BlocProvider(
      create: (context) => sl<TaskBloc>(),
      child: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskOperationSuccess) {
            _shouldRefresh = true;
            setState(() => _task = state.task);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Task status updated.')),
            );
          } else if (state is TaskSubmissionSuccess) {
            _shouldRefresh = true;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Submission received.')),
            );
            Navigator.of(context).pop(true);
          } else if (state is TaskPaymentSuccess) {
            _shouldRefresh = true;
            setState(() => _task = _task.copyWith(status: TaskStatus.paid));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment completed: \$${state.amountPaid}.'),
              ),
            );
          } else if (state is TaskDownloadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Solution downloaded.')),
            );
          } else if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is TaskLoading;
          return WillPopScope(
            onWillPop: () async {
              Navigator.of(context).pop(_shouldRefresh);
              return false;
            },
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Task Details'),
              ),
              body: SafeArea(
                child: Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _task.title,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _task.description,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 8,
                                  children: [
                                    _InfoChip(
                                      icon: Icons.timer_outlined,
                                      label:
                                          '\$${_task.hourlyRate.toStringAsFixed(0)}/hr',
                                    ),
                                    _InfoChip(
                                      icon: Icons.person_outline,
                                      label: 'Developer ${_task.assigneeId}',
                                    ),
                                    _InfoChip(
                                      icon: Icons.track_changes_outlined,
                                      label: _task.status.label,
                                    ),
                                  ],
                                ),
                                if (_task.timeSpent != null) ...[
                                  const SizedBox(height: 16),
                                  Text(
                                    'Time logged: ${_task.timeSpent!.toStringAsFixed(1)} hours',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (isBuyer)
                          ..._buildBuyerActions(context, theme, amountDue),
                        if (!isBuyer)
                          ..._buildDeveloperActions(context, theme),
                      ],
                    ),
                    if (isLoading)
                      Container(
                        color: Colors.black.withOpacity(0.05),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
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

  List<Widget> _buildBuyerActions(
    BuildContext context,
    ThemeData theme,
    double amountDue,
  ) {
    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submission access',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _task.status == TaskStatus.submitted
                    ? 'Payment is required to unlock the solution.'
                    : _task.status == TaskStatus.paid
                        ? 'Solution unlocked. You can download the zip.'
                        : 'Waiting on developer submission.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              if (_task.status == TaskStatus.submitted) ...[
                const SizedBox(height: 16),
                Text(
                  'Amount due: \$${amountDue.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      context.read<TaskBloc>().add(PayTaskRequested(_task.id)),
                  child: const Text('Pay now'),
                ),
              ],
              if (_task.status == TaskStatus.paid) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _downloadSolution(context),
                  icon: const Icon(Icons.download),
                  label: const Text('Download solution zip'),
                ),
              ],
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildDeveloperActions(BuildContext context, ThemeData theme) {
    final submissionLocked = _task.status == TaskStatus.submitted ||
        _task.status == TaskStatus.paid;
    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update task',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              if (_task.status == TaskStatus.todo)
                FilledButton(
                  onPressed: () {
                    context.read<TaskBloc>().add(
                          UpdateTaskStatusRequested(
                            _task.id,
                            TaskStatus.inProgress,
                          ),
                        );
                  },
                  child: const Text('Start task'),
                ),
              if (_task.status == TaskStatus.inProgress)
                OutlinedButton(
                  onPressed: () {
                    context.read<TaskBloc>().add(
                          UpdateTaskStatusRequested(
                            _task.id,
                            TaskStatus.todo,
                          ),
                        );
                  },
                  child: const Text('Move back to todo'),
                ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Submit solution',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (submissionLocked) ...[
                const SizedBox(height: 8),
                Text(
                  'Submission already sent.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _hoursController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Hours spent',
                ),
                enabled: !submissionLocked,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedFilePath == null
                          ? 'No zip file selected'
                          : _selectedFilePath!.split('/').last,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: submissionLocked ? null : _pickZipFile,
                    child: const Text('Attach zip'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: submissionLocked
                    ? null
                    : () {
                        final hours = double.tryParse(_hoursController.text);
                        if (hours == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Enter valid hours.'),
                            ),
                          );
                          return;
                        }
                        context.read<TaskBloc>().add(
                              SubmitTaskRequested(
                                _task.id,
                                hours,
                                _selectedFilePath,
                              ),
                            );
                      },
                child: const Text('Submit work'),
              ),
            ],
          ),
        ),
      ),
    ];
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
