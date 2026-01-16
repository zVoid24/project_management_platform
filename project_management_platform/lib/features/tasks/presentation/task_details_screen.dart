import 'package:file_picker/file_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/task.dart';
import 'task_bloc.dart';
import '../../../injection_container.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_widgets.dart';

enum TaskDetailsMode { buyer, developer }

class TaskDetailsScreen extends StatefulWidget {
  final Task task;
  final TaskDetailsMode mode;
  const TaskDetailsScreen({super.key, required this.task, required this.mode});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late Task _task;
  final _hoursController = TextEditingController();
  String? _selectedFilePath;
  bool _shouldRefresh = false;
  String? _cachedDownloadPath;

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
    // Avoid FilePicker.saveFile on mobile crash.
    // Use path_provider to get a safe directory.
    final directory = await getApplicationDocumentsDirectory();
    final savePath = '${directory.path}/task_${_task.id}_solution.zip';
    _cachedDownloadPath = savePath;

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Downloading to $savePath...')));
      context.read<TaskBloc>().add(
        DownloadSolutionRequested(_task.id, savePath),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            setState(
              () => _task = _task.copyWith(status: TaskStatus.submitted),
            );
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
              const SnackBar(
                content: Text('Download complete. Opening file...'),
              ),
            );
            if (_cachedDownloadPath != null) {
              OpenFile.open(_cachedDownloadPath);
            }
          } else if (state is TaskError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
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
              appBar: AppBar(title: const Text('Task Details')),
              body: SafeArea(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          PremiumCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _task.title,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge,
                                      ),
                                    ),
                                    StatusChip.forStatus(_task.status),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _task.description,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(height: 1.5),
                                ),
                                const SizedBox(height: 20),
                                const Divider(height: 1),
                                const SizedBox(height: 20),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 12,
                                  children: [
                                    _DetailItem(
                                      icon: Icons.attach_money,
                                      label:
                                          '${_task.hourlyRate.toStringAsFixed(0)}/hr',
                                    ),
                                    _DetailItem(
                                      icon: Icons.person_outline,
                                      label: 'Dev ${_task.assigneeId}',
                                    ),
                                    if (_task.timeSpent != null)
                                      _DetailItem(
                                        icon: Icons.timer,
                                        label:
                                            '${_task.timeSpent!.toStringAsFixed(1)} hrs',
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (isBuyer)
                            ..._buildBuyerActions(context, amountDue),
                          if (!isBuyer) ..._buildDeveloperActions(context),
                        ],
                      ),
                    ),
                    if (isLoading)
                      Container(
                        color: Colors.black.withOpacity(0.1),
                        child: const Center(child: CircularProgressIndicator()),
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

  List<Widget> _buildBuyerActions(BuildContext context, double amountDue) {
    return [
      PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Action Required',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (_task.status == TaskStatus.submitted) ...[
              Text(
                'Review the work and pay to unlock the solution.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '\$${amountDue.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppTheme.darkNavy,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () =>
                      context.read<TaskBloc>().add(PayTaskRequested(_task.id)),
                  icon: const Icon(Icons.lock_open),
                  label: const Text('Pay to Unlock'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                  ),
                ),
              ),
            ] else if (_task.status == TaskStatus.paid) ...[
              Text(
                'Payment complete. You can now download the deliverables.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _downloadSolution(context),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Download ZIP'),
                ),
              ),
            ] else ...[
              Text(
                'Waiting for developer to submit work.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textGrey),
              ),
            ],
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildDeveloperActions(BuildContext context) {
    final submissionLocked =
        _task.status == TaskStatus.submitted || _task.status == TaskStatus.paid;

    return [
      PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            if (_task.status == TaskStatus.todo)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    context.read<TaskBloc>().add(
                      UpdateTaskStatusRequested(
                        _task.id,
                        TaskStatus.inProgress,
                      ),
                    );
                  },
                  child: const Text('Start Working'),
                ),
              )
            else if (_task.status == TaskStatus.inProgress)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    context.read<TaskBloc>().add(
                      UpdateTaskStatusRequested(_task.id, TaskStatus.todo),
                    );
                  },
                  child: const Text('Mark as Todo'),
                ),
              )
            else
              const Text('Task is submitted/completed.'),
          ],
        ),
      ),
      const SizedBox(height: 20),
      PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Submission', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (submissionLocked)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.successGreen,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Submission Received',
                      style: TextStyle(
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              TextField(
                controller: _hoursController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Hours Worked',
                  prefixIcon: Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickZipFile,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.darkNavy.withOpacity(0.1),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: AppTheme.surfaceGrey,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.folder_zip, color: AppTheme.primaryBlue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedFilePath == null
                              ? 'Tap to select ZIP file'
                              : _selectedFilePath!.split('/').last,
                          style: TextStyle(
                            color: _selectedFilePath == null
                                ? AppTheme.textGrey
                                : AppTheme.darkNavy,
                          ),
                        ),
                      ),
                      if (_selectedFilePath != null)
                        const Icon(Icons.check, color: AppTheme.successGreen),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final hours = double.tryParse(_hoursController.text);
                    if (hours == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter valid hours.'),
                        ),
                      );
                      return;
                    }
                    context.read<TaskBloc>().add(
                      SubmitTaskRequested(_task.id, hours, _selectedFilePath),
                    );
                  },
                  child: const Text('Submit Solution'),
                ),
              ),
            ],
          ],
        ),
      ),
    ];
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: AppTheme.textGrey),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppTheme.darkNavy,
          ),
        ),
      ],
    );
  }
}
