import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mlq_queue_config.dart';
import '../providers/mlq_config_provider.dart';

class MLQQueueConfigDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<MLQQueueConfigDialog> createState() => _MLQQueueConfigDialogState();
}

class _MLQQueueConfigDialogState extends ConsumerState<MLQQueueConfigDialog> {
  @override
  Widget build(BuildContext context) {
    final queueConfigs = ref.watch(mlqConfigProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Queue Configuration',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: queueConfigs.length,
                itemBuilder: (context, index) {
                  final config = queueConfigs[index];
                  return _buildQueueConfigCard(config, isDark);
                },
              ),
            ),
            const SizedBox(height: 20),
            // Action buttons in a more compact layout
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => ref.read(mlqConfigProvider.notifier).addQueue(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Queue'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => ref.read(mlqConfigProvider.notifier).resetToDefault(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Done'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueueConfigCard(MLQQueueConfig config, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Q${config.queueNumber} - ${config.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (ref.read(mlqConfigProvider).length > 1)
                  IconButton(
                    onPressed: () => ref.read(mlqConfigProvider.notifier).removeQueue(config.queueNumber),
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Use Wrap for responsive layout
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Algorithm dropdown
                SizedBox(
                  width: 150,
                  child: DropdownButtonFormField<String>(
                    value: config.algorithm,
                    decoration: const InputDecoration(
                      labelText: 'Algorithm',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    isDense: true,
                    items: ['FCFS', 'SJF', 'SRTF', 'Round Robin', 'Priority']
                        .map((algo) => DropdownMenuItem(
                              value: algo,
                              child: Text(algo, style: const TextStyle(fontSize: 12)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(mlqConfigProvider.notifier).updateQueue(
                          config.queueNumber,
                          config.copyWith(algorithm: value),
                        );
                      }
                    },
                  ),
                ),
                // Time quantum field (only for Round Robin)
                if (config.algorithm == 'Round Robin')
                  SizedBox(
                    width: 120,
                    child: TextFormField(
                      initialValue: config.timeQuantum?.toString() ?? '4',
                      decoration: const InputDecoration(
                        labelText: 'Time Quantum',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 12),
                      onChanged: (value) {
                        final quantum = int.tryParse(value);
                        if (quantum != null) {
                          ref.read(mlqConfigProvider.notifier).updateQueue(
                            config.queueNumber,
                            config.copyWith(timeQuantum: quantum),
                          );
                        }
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
