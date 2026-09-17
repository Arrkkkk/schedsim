import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mlq_process.dart';
import '../providers/mlq_process_provider.dart';

class MLQProcessInputForm extends ConsumerWidget {
  const MLQProcessInputForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final processes = ref.watch(mlqProcessListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Enhanced header with MLQ-specific styling
        Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark ? [
                Colors.purple.withOpacity(0.2),
                Colors.purple.withOpacity(0.1),
              ] : [
                Colors.purple.withOpacity(0.1),
                Colors.purple.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.purple.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MLQ Processes',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${processes.length} added',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildActionButton(
                        context: context,
                        icon: Icons.auto_awesome_rounded,
                        label: 'Example',
                        onPressed: () => ref
                            .read(mlqProcessListProvider.notifier)
                            .loadExampleProcesses(),
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        context: context,
                        icon: Icons.shuffle_rounded,
                        label: 'Random',
                        onPressed: () => ref
                            .read(mlqProcessListProvider.notifier)
                            .generateRandomProcesses(5),
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        context: context,
                        icon: Icons.clear_all_rounded,
                        label: 'Clear',
                        onPressed: processes.isEmpty
                            ? null
                            : () => ref
                                  .read(mlqProcessListProvider.notifier)
                                  .clearProcesses(),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Queue information
              _buildQueueInfo(context, isDark),
            ],
          ),
        ),
        
        // Enhanced content area
        Expanded(
          child: processes.isEmpty
              ? _buildEmptyState(context)
              : _buildProcessList(context, ref, processes),
        ),
      ],
    );
  }

  Widget _buildQueueInfo(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Queue Configuration:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildQueueRow('Q1 (Interactive)', 'Round Robin (TQ=4ms)', Colors.green, isDark),
          _buildQueueRow('Q2 (Batch)', 'FCFS', Colors.orange, isDark),
          _buildQueueRow('Q3 (Background)', 'FCFS', Colors.red, isDark),
        ],
      ),
    );
  }

  Widget _buildQueueRow(String queue, String algorithm, Color color, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$queue: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            algorithm,
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Enhanced empty state icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.2),
                  Colors.purple.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.purple.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.queue_play_next_rounded,
              size: 64,
              color: Colors.purple.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          
          // Enhanced text with better styling
          Text(
            'No MLQ processes added yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.purple.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Tap the + button below to add a process\nor use the Example button above',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.purple.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessList(BuildContext context, WidgetRef ref, List<MLQProcess> processes) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: processes.length,
      itemBuilder: (context, index) {
        final process = processes[index];
        final queueColor = _getQueueColor(process.queue);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 2,
            color: isDark ? Colors.grey[850] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: isDark ? [
                    Colors.grey[850]!,
                    Colors.grey[800]!,
                  ] : [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        queueColor,
                        queueColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: queueColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      process.id,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  'Process ${process.id}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _buildInfoChip('AT: ${process.arrivalTime}', Colors.blue, isDark),
                      _buildInfoChip('BT: ${process.burstTime}', Colors.green, isDark),
                      _buildInfoChip('P: ${process.priority}', Colors.orange, isDark),
                      _buildInfoChip('Q${process.queue}', queueColor, isDark),
                    ],
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIconButton(
                      context: context,
                      icon: Icons.edit_rounded,
                      onPressed: () => _editProcess(context, ref, index, process),
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildIconButton(
                      context: context,
                      icon: Icons.delete_rounded,
                      onPressed: () => ref
                          .read(mlqProcessListProvider.notifier)
                          .removeProcess(index),
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getQueueColor(int queue) {
    switch (queue) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoChip(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? color.withOpacity(0.2) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? color.withOpacity(0.5) : color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isDark ? color.withOpacity(0.9) : color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        style: IconButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _editProcess(
    BuildContext context,
    WidgetRef ref,
    int index,
    MLQProcess process,
  ) {
    showDialog(
      context: context,
      builder: (context) => MLQProcessInputDialog(
        process: process,
        onSave: (updatedProcess) {
          ref
              .read(mlqProcessListProvider.notifier)
              .updateProcess(index, updatedProcess);
        },
      ),
    );
  }
}

class MLQProcessInputDialog extends StatefulWidget {
  final MLQProcess? process;
  final Function(MLQProcess)? onSave;

  const MLQProcessInputDialog({Key? key, this.process, this.onSave})
    : super(key: key);

  @override
  State<MLQProcessInputDialog> createState() => _MLQProcessInputDialogState();
}

class _MLQProcessInputDialogState extends State<MLQProcessInputDialog> {
  late final TextEditingController _idController;
  late final TextEditingController _arrivalController;
  late final TextEditingController _burstController;
  late final TextEditingController _priorityController;
  late int _selectedQueue;
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
    _selectedQueue = widget.process?.queue ?? 1;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: isDark ? [
                Colors.grey[850]!,
                Colors.grey[800]!,
              ] : [
                Colors.white,
                Colors.grey.shade50,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Enhanced header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple,
                        Colors.purple.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          widget.process == null ? Icons.add_rounded : Icons.edit_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.process == null ? 'Add MLQ Process' : 'Edit MLQ Process',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Enhanced form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _idController,
                        label: 'Process ID',
                        icon: Icons.tag_rounded,
                        validator: (value) => value?.isEmpty == true ? 'Required' : null,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _arrivalController,
                        label: 'Arrival Time',
                        icon: Icons.schedule_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final num = int.tryParse(value ?? '');
                          return num == null || num < 0 ? 'Enter valid number ≥ 0' : null;
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _burstController,
                        label: 'Burst Time',
                        icon: Icons.timer_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final num = int.tryParse(value ?? '');
                          return num == null || num <= 0 ? 'Enter valid number > 0' : null;
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _priorityController,
                        label: 'Priority (lower = higher priority)',
                        icon: Icons.star_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final num = int.tryParse(value ?? '');
                          return num == null ? 'Enter valid number' : null;
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: 12),
                      _buildQueueSelector(isDark),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Enhanced action buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        label: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                        color: Colors.grey,
                        isOutlined: true,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        label: 'Save',
                        onPressed: _saveProcess,
                        color: Colors.purple,
                        icon: Icons.check_rounded,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQueueSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Queue:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQueueOption(1, 'Q1 (Interactive)', Colors.green, isDark),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQueueOption(2, 'Q2 (Batch)', Colors.orange, isDark),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQueueOption(3, 'Q3 (Background)', Colors.red, isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQueueOption(int queue, String label, Color color, bool isDark) {
    final isSelected = _selectedQueue == queue;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedQueue = queue),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? color.withOpacity(0.2) 
              : (isDark ? Colors.grey[700] : Colors.grey[200]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? color 
                    : (isDark ? Colors.white : Colors.black87),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.purple,
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[600]! : Colors.grey.withOpacity(0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[600]! : Colors.grey.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.purple,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: isDark ? Colors.grey[800] : Colors.white,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    IconData? icon,
    bool isOutlined = false,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.transparent : color,
          foregroundColor: isOutlined ? color : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isOutlined ? BorderSide(color: color, width: 2) : BorderSide.none,
          ),
          elevation: 0,
        ),
      ),
    );
  }

  void _saveProcess() {
    if (!_formKey.currentState!.validate()) return;

    final ref = ProviderScope.containerOf(context);
    final existingProcesses = ref.read(mlqProcessListProvider);
    final processId = _idController.text.trim();

    // Check for duplicate process ID
    if (widget.process == null) {
      // Adding new process - check for duplicates
      final isDuplicate = existingProcesses.any((p) => p.id == processId);
      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Process ID "$processId" already exists! Please use a different ID.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
    } else {
      // Editing existing process - check for duplicates (excluding current process)
      final isDuplicate = existingProcesses.any((p) => p.id == processId && p != widget.process);
      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Process ID "$processId" already exists! Please use a different ID.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    final process = MLQProcess(
      id: processId,
      arrivalTime: int.parse(_arrivalController.text),
      burstTime: int.parse(_burstController.text),
      priority: int.parse(_priorityController.text),
      queue: _selectedQueue,
    );

    if (widget.onSave != null) {
      widget.onSave!(process);
    } else {
      // Add new process
      ref.read(mlqProcessListProvider.notifier).addProcess(process);
    }

    Navigator.pop(context);
  }
}
