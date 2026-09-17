import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/process.dart';
import '../models/schedule_result.dart';
import '../providers/process_provider.dart';
import '../services/scheduling_algorithms.dart';
import '../widgets/process_input_form.dart';
import '../widgets/gantt_chart_widget.dart';
import '../widgets/results_table_widget.dart';
import '../widgets/steps_widget.dart';
import '../widgets/comparison_widget.dart';
import '../services/export_service.dart';

class AlgorithmScreen extends ConsumerStatefulWidget {
  final String algorithm;

  const AlgorithmScreen({Key? key, required this.algorithm}) : super(key: key);

  @override
  ConsumerState<AlgorithmScreen> createState() => _AlgorithmScreenState();
}

class _AlgorithmScreenState extends ConsumerState<AlgorithmScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ScheduleResult? _result;
  List<ScheduleResult>? _comparisonResults;
  int _quantum = 2;
  bool _isPreemptive = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.algorithm == 'Compare' ? 1 : 4,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final processes = ref.watch(processListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAlgorithmTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: processes.isEmpty ? null : _runSimulation,
            tooltip: 'Run Simulation',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _clearResults,
            tooltip: 'Clear Results',
          ),
          if (widget.algorithm != 'Compare')
            PopupMenuButton<String>(
              onSelected: _handleMenuSelection,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'export_pdf',
                  child: Text('Export PDF'),
                ),
                const PopupMenuItem(
                  value: 'export_csv',
                  child: Text('Export CSV'),
                ),
                const PopupMenuItem(
                  value: 'random',
                  child: Text('Generate Random Processes'),
                ),
              ],
            ),
        ],
        bottom: widget.algorithm != 'Compare'
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Input', icon: Icon(Icons.input)),
                  Tab(text: 'Gantt Chart', icon: Icon(Icons.timeline)),
                  Tab(text: 'Results', icon: Icon(Icons.table_chart)),
                  Tab(text: 'Steps', icon: Icon(Icons.list)),
                ],
              )
            : null,
      ),
      body: widget.algorithm == 'Compare'
          ? _buildComparisonView(processes)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildInputTab(),
                _buildGanttTab(),
                _buildResultsTab(),
                _buildStepsTab(),
              ],
            ),
      floatingActionButton: widget.algorithm != 'Compare'
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () => _showProcessInputDialog(context),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            )
          : null,
    );
  }

  String _getAlgorithmTitle() {
    switch (widget.algorithm) {
      case 'FCFS':
        return 'First Come First Serve';
      case 'SJF':
        return 'Shortest Job First';
      case 'SRTF':
        return 'Shortest Remaining Time First';
      case 'RR':
        return 'Round Robin';
      case 'Priority':
        return 'Priority Scheduling';
      case 'Compare':
        return 'Algorithm Comparison';
      default:
        return 'CPU Scheduler';
    }
  }

  Widget _buildInputTab() {
    return Column(
      children: [
        if (widget.algorithm == 'RR') _buildQuantumInput(),
        if (widget.algorithm == 'SJF' || widget.algorithm == 'Priority')
          _buildPreemptiveToggle(),
        const Expanded(child: ProcessInputForm()),
      ],
    );
  }

  Widget _buildQuantumInput() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text('Time Quantum: ', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 16),
            SizedBox(
              width: 100,
              child: TextFormField(
                initialValue: _quantum.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
                onChanged: (value) {
                  final quantum = int.tryParse(value);
                  if (quantum != null && quantum > 0) {
                    setState(() => _quantum = quantum);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreemptiveToggle() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              '${widget.algorithm} Mode: ',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 16),
            Switch(
              value: _isPreemptive,
              onChanged: (value) => setState(() => _isPreemptive = value),
            ),
            Text(_isPreemptive ? 'Preemptive' : 'Non-Preemptive'),
          ],
        ),
      ),
    );
  }

  Widget _buildGanttTab() {
    if (_result == null) {
      return const Center(
        child: Text(
          'Run simulation to see Gantt Chart',
          style: TextStyle(fontSize: 18),
        ),
      );
    }
    return GanttChartWidget(result: _result!);
  }

  Widget _buildResultsTab() {
    if (_result == null) {
      return const Center(
        child: Text(
          'Run simulation to see results',
          style: TextStyle(fontSize: 18),
        ),
      );
    }
    return ResultsTableWidget(result: _result!);
  }

  Widget _buildStepsTab() {
    if (_result == null) {
      return const Center(
        child: Text(
          'Run simulation to see step-by-step solution',
          style: TextStyle(fontSize: 18),
        ),
      );
    }
    return StepsWidget(steps: _result!.steps);
  }

  Widget _buildComparisonView(List<Process> processes) {
    if (processes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare_arrows, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Add processes to compare algorithms',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      );
    }

    if (_comparisonResults == null) {
      return Column(
        children: [
          const ProcessInputForm(),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _runComparison,
            icon: const Icon(Icons.compare_arrows),
            label: const Text('Compare All Algorithms'),
          ),
        ],
      );
    }

    return ComparisonWidget(results: _comparisonResults!);
  }

  void _runSimulation() {
    final processes = ref.read(processListProvider);
    if (processes.isEmpty) return;

    ScheduleResult result;
    switch (widget.algorithm) {
      case 'FCFS':
        result = SchedulingAlgorithms.fcfs(processes);
        break;
      case 'SJF':
        result = _isPreemptive
            ? SchedulingAlgorithms.sjfPreemptive(processes)
            : SchedulingAlgorithms.sjfNonPreemptive(processes);
        break;
      case 'SRTF':
        result = SchedulingAlgorithms.sjfPreemptive(processes);
        break;
      case 'RR':
        result = SchedulingAlgorithms.roundRobin(processes, _quantum);
        break;
      case 'Priority':
        result = _isPreemptive
            ? SchedulingAlgorithms.priorityPreemptive(processes)
            : SchedulingAlgorithms.priorityNonPreemptive(processes);
        break;
      default:
        return;
    }

    setState(() => _result = result);
    _tabController.animateTo(1); // Switch to Gantt chart tab
  }

  void _runComparison() {
    final processes = ref.read(processListProvider);
    if (processes.isEmpty) return;

    final results = <ScheduleResult>[
      SchedulingAlgorithms.fcfs(processes),
      SchedulingAlgorithms.sjfNonPreemptive(processes),
      SchedulingAlgorithms.sjfPreemptive(processes),
      SchedulingAlgorithms.roundRobin(processes, 2),
      SchedulingAlgorithms.priorityNonPreemptive(processes),
      SchedulingAlgorithms.priorityPreemptive(processes),
    ];

    setState(() => _comparisonResults = results);
  }

  void _clearResults() {
    setState(() {
      _result = null;
      _comparisonResults = null;
    });
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'export_pdf':
        _exportPDF();
        break;
      case 'export_csv':
        _exportCSV();
        break;
      case 'random':
        _generateRandomProcesses();
        break;
    }
  }

  Future<void> _exportPDF() async {
    if (_result == null) {
      _showMessage('Please run the simulation first before exporting');
      return;
    }

    try {
      _showLoadingMessage('Generating PDF...');
      final filePath = await ExportService.exportToPDF(
        _result!,
        _getAlgorithmTitle(),
      );
      Navigator.of(context).pop(); // Dismiss loading dialog
      _showSuccessDialog('PDF Export Successful', 'PDF saved to:\n$filePath');
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss loading dialog
      _showMessage('Failed to export PDF: ${e.toString()}');
    }
  }

  void _exportCSV() {
    // TODO: Implement CSV export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CSV export feature coming soon!')),
    );
  }

  void _generateRandomProcesses() {
    ref.read(processListProvider.notifier).generateRandomProcesses(5);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generated 5 random processes')),
    );
  }

  void _showProcessInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ProcessInputDialog(),
    );
  }

  // NEW: User feedback methods
  void _showMessage(String message) {
    /* Error messages */
  }
  void _showLoadingMessage(String message) {
    /* Loading dialog */
  }
  void _showSuccessDialog(String title, String message) {
    /* Success dialog */
  }
}
