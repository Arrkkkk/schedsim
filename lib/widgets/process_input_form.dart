import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/process.dart';
import '../providers/process_provider.dart';

class ProcessInputForm extends ConsumerWidget {
  const ProcessInputForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final processes = ref.watch(processListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Enhanced header with better styling
        Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark ? [
                Theme.of(context).primaryColor.withOpacity(0.2),
                Theme.of(context).primaryColor.withOpacity(0.1),
              ] : [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Theme.of(context).primaryColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Processes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
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
                    icon: Icons.shuffle_rounded,
                    label: 'Random',
                    onPressed: () => ref
                        .read(processListProvider.notifier)
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
                              .read(processListProvider.notifier)
                              .clearProcesses(),
                    color: Colors.red,
                  ),
                ],
              ),
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
                colors: isDark ? [
                  Theme.of(context).primaryColor.withOpacity(0.2),
                  Theme.of(context).primaryColor.withOpacity(0.1),
                ] : [
                  Theme.of(context).primaryColor.withOpacity(0.1),
                  Theme.of(context).primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.add_circle_outline_rounded,
              size: 64,
              color: Theme.of(context).primaryColor.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 24),
          
          // Enhanced text with better styling
          Text(
            'No processes added yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Tap the + button below to add a process\nor use the Random button above',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).primaryColor.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessList(BuildContext context, WidgetRef ref, List<Process> processes) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: processes.length,
      itemBuilder: (context, index) {
        final process = processes[index];
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
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
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
                          .read(processListProvider.notifier)
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
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
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
                        widget.process == null ? 'Add New Process' : 'Edit Process',
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
                        color: Theme.of(context).primaryColor,
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
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
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
              color: Theme.of(context).primaryColor,
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
    final existingProcesses = ref.read(processListProvider);
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

    final process = Process(
      id: processId,
      arrivalTime: int.parse(_arrivalController.text),
      burstTime: int.parse(_burstController.text),
      priority: int.parse(_priorityController.text),
    );

    if (widget.onSave != null) {
      widget.onSave!(process);
    } else {
      // Add new process
      ref.read(processListProvider.notifier).addProcess(process);
    }

    Navigator.pop(context);
  }
}
