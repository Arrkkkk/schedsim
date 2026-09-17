import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/process.dart';
import '../providers/process_provider.dart';

class ProcessInputForm extends ConsumerWidget {
  const ProcessInputForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final processes = ref.watch(processListProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Processes (${processes.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => ref
                        .read(processListProvider.notifier)
                        .generateRandomProcesses(5),
                    icon: const Icon(Icons.shuffle),
                    label: const Text('Random'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: processes.isEmpty
                        ? null
                        : () => ref
                              .read(processListProvider.notifier)
                              .clearProcesses(),
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: processes.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text('No processes added yet'),
                      SizedBox(height: 8),
                      Text('Tap + to add a process or use Random button'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: processes.length,
                  itemBuilder: (context, index) {
                    final process = processes[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text(process.id)),
                        title: Text('Process ${process.id}'),
                        subtitle: Text(
                          'AT: ${process.arrivalTime}, BT: ${process.burstTime}, Priority: ${process.priority}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _editProcess(context, ref, index, process),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => ref
                                  .read(processListProvider.notifier)
                                  .removeProcess(index),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _editProcess(
    BuildContext context,
    WidgetRef ref,
    int index,
    Process process,
  ) {
    showDialog(
      context: context,
      builder: (context) => ProcessInputDialog(
        process: process,
        onSave: (updatedProcess) {
          ref
              .read(processListProvider.notifier)
              .updateProcess(index, updatedProcess);
        },
      ),
    );
  }
}

class ProcessInputDialog extends StatefulWidget {
  final Process? process;
  final Function(Process)? onSave;

  const ProcessInputDialog({Key? key, this.process, this.onSave})
    : super(key: key);

  @override
  State<ProcessInputDialog> createState() => _ProcessInputDialogState();
}

class _ProcessInputDialogState extends State<ProcessInputDialog> {
  late final TextEditingController _idController;
  late final TextEditingController _arrivalController;
  late final TextEditingController _burstController;
  late final TextEditingController _priorityController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.process?.id ?? '');
    _arrivalController = TextEditingController(
      text: widget.process?.arrivalTime.toString() ?? '0',
    );
    _burstController = TextEditingController(
      text: widget.process?.burstTime.toString() ?? '1',
    );
    _priorityController = TextEditingController(
      text: widget.process?.priority.toString() ?? '1',
    );
  }

  @override
  void dispose() {
    _idController.dispose();
    _arrivalController.dispose();
    _burstController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.process == null ? 'Add Process' : 'Edit Process'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Process ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _arrivalController,
              decoration: const InputDecoration(
                labelText: 'Arrival Time',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                final num = int.tryParse(value ?? '');
                return num == null || num < 0 ? 'Enter valid number ≥ 0' : null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _burstController,
              decoration: const InputDecoration(
                labelText: 'Burst Time',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                final num = int.tryParse(value ?? '');
                return num == null || num <= 0
                    ? 'Enter valid number > 0'
                    : null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priorityController,
              decoration: const InputDecoration(
                labelText: 'Priority (lower = higher priority)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                final num = int.tryParse(value ?? '');
                return num == null ? 'Enter valid number' : null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: _saveProcess, child: const Text('Save')),
      ],
    );
  }

  void _saveProcess() {
    if (!_formKey.currentState!.validate()) return;

    final process = Process(
      id: _idController.text,
      arrivalTime: int.parse(_arrivalController.text),
      burstTime: int.parse(_burstController.text),
      priority: int.parse(_priorityController.text),
    );

    if (widget.onSave != null) {
      widget.onSave!(process);
    } else {
      // Add new process
      final ref = ProviderScope.containerOf(context);
      ref.read(processListProvider.notifier).addProcess(process);
    }

    Navigator.pop(context);
  }
}
