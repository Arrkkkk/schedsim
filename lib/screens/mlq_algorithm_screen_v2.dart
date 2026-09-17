import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/mlq_process_provider.dart';
import '../providers/mlq_config_provider.dart';
import '../services/mlq_scheduling_v2.dart';
import '../widgets/mlq_process_input_form_v2.dart';
import '../widgets/gantt_chart_widget.dart';
import '../widgets/results_table_widget.dart';
import '../widgets/steps_widget.dart';
import '../models/schedule_result.dart';

class MLQAlgorithmScreenV2 extends ConsumerStatefulWidget {
  const MLQAlgorithmScreenV2({Key? key}) : super(key: key);

  @override
  ConsumerState<MLQAlgorithmScreenV2> createState() => _MLQAlgorithmScreenV2State();
}

class _MLQAlgorithmScreenV2State extends ConsumerState<MLQAlgorithmScreenV2>
    with TickerProviderStateMixin {
  late TabController _tabController;
  ScheduleResult? _result;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _runMLQ() {
    final processes = ref.read(mlqProcessListProvider);
    final queueConfigs = ref.read(mlqConfigProvider);
    
    print('MLQ Debug: Button pressed. Processes: ${processes.length}, QueueConfigs: ${queueConfigs.length}');
    print('MLQ Debug: Processes: ${processes.map((p) => '${p.id}(Q${p.queue})').join(', ')}');
    print('MLQ Debug: Queue configs: ${queueConfigs.map((q) => 'Q${q.queueNumber}-${q.algorithm}').join(', ')}');
    
    if (processes.isEmpty) {
      print('MLQ Debug: No processes found');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one process before running MLQ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (queueConfigs.isEmpty) {
      print('MLQ Debug: No queue configs found');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please configure at least one queue'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      print('MLQ Debug: Starting scheduling with ${processes.length} processes and ${queueConfigs.length} queue configs');
      
      // Create copies of processes to avoid mutating originals
      final processCopies = processes.map((p) => p.copy()).toList();
      
      setState(() {
        print('MLQ Debug: Setting result');
        _result = MLQSchedulingV2.schedule(processCopies, queueConfigs);
        print('MLQ Debug: Result created with ${_result?.ganttChart.length ?? 0} gantt segments');
      });

      // Switch to results tab
      _tabController.animateTo(1);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('MLQ scheduling completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e, stackTrace) {
      print('MLQ Error: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error running MLQ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final processes = ref.watch(mlqProcessListProvider);
    final queueConfigs = ref.watch(mlqConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MLQ Scheduling'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.list_alt), text: 'Processes'),
            Tab(icon: Icon(Icons.analytics), text: 'Results'),
            Tab(icon: Icon(Icons.timeline), text: 'Gantt Chart'),
            Tab(icon: Icon(Icons.info), text: 'Steps'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Processes Tab
          const MLQProcessInputFormV2(),
          
          // Results Tab
          _result != null
              ? _buildResultsTab()
              : _buildEmptyResultsTab(),
          
          // Gantt Chart Tab
          _result != null
              ? _buildGanttChartTab()
              : _buildEmptyGanttTab(),
          
          // Steps Tab
          _result != null
              ? _buildStepsTab()
              : _buildEmptyStepsTab(),
        ],
      ),
      floatingActionButton: Container(
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
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _runMLQ,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
          label: const Text(
            'Run MLQ',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MLQ-specific header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.queue_play_next_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'MLQ Scheduling Results',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Multi-Level Queue with Dynamic Configuration',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Metrics cards
          _buildMetricsCards(),
          
          const SizedBox(height: 20),
          
          // Results table
          ResultsTableWidget(result: _result!),
        ],
      ),
    );
  }

  Widget _buildMetricsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Avg Turnaround Time',
            _result!.averageTurnaroundTime.toStringAsFixed(2),
            Colors.blue,
            Icons.timer_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Avg Waiting Time',
            _result!.averageWaitingTime.toStringAsFixed(2),
            Colors.orange,
            Icons.hourglass_empty_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            'Avg Response Time',
            _result!.averageResponseTime.toStringAsFixed(2),
            Colors.green,
            Icons.flash_on_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResultsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No results yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add processes and run MLQ to see results',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGanttChartTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.timeline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'MLQ Gantt Chart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GanttChartWidget(result: _result!),
        ],
      ),
    );
  }

  Widget _buildEmptyGanttTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Gantt chart yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Run MLQ to generate the execution timeline',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'MLQ Execution Steps',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          StepsWidget(steps: _result!.steps),
        ],
      ),
    );
  }

  Widget _buildEmptyStepsTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No steps yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Run MLQ to see the execution steps',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
