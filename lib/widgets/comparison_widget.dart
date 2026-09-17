import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/schedule_result.dart';

class ComparisonWidget extends StatefulWidget {
  final List<ScheduleResult> results;

  const ComparisonWidget({Key? key, required this.results}) : super(key: key);

  @override
  State<ComparisonWidget> createState() => _ComparisonWidgetState();
}

class _ComparisonWidgetState extends State<ComparisonWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _algorithmNames = [
    'FCFS',
    'SJF (NP)',
    'SJF (P)',
    'Round Robin',
    'Priority (NP)',
    'Priority (P)',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Charts', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Table', icon: Icon(Icons.table_view)),
            Tab(text: 'Best Algorithm', icon: Icon(Icons.star)),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildChartsView(),
              _buildTableView(),
              _buildBestAlgorithmView(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartsView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: _buildMetricChart(
              'Average Turnaround Time',
              _getTurnaroundTimes(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildMetricChart(
              'Average Waiting Time',
              _getWaitingTimes(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildMetricChart(
              'CPU Utilization (%)',
              _getCpuUtilizations(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChart(String title, List<double> values) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: values.reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${_algorithmNames[group.x.toInt()]}\n${rod.toY.toStringAsFixed(2)}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _algorithmNames[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: values.asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: _getBarColor(entry.key),
                          width: 20,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Algorithm Comparison Table',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Algorithm')),
                      DataColumn(label: Text('Avg TAT')),
                      DataColumn(label: Text('Avg WT')),
                      DataColumn(label: Text('Avg RT')),
                      DataColumn(label: Text('CPU Util %')),
                      DataColumn(label: Text('Throughput')),
                    ],
                    rows: widget.results.asMap().entries.map((entry) {
                      final index = entry.key;
                      final result = entry.value;
                      return DataRow(
                        cells: [
                          DataCell(Text(_algorithmNames[index])),
                          DataCell(
                            Text(
                              result.averageTurnaroundTime.toStringAsFixed(2),
                            ),
                          ),
                          DataCell(
                            Text(result.averageWaitingTime.toStringAsFixed(2)),
                          ),
                          DataCell(
                            Text(result.averageResponseTime.toStringAsFixed(2)),
                          ),
                          DataCell(
                            Text(result.cpuUtilization.toStringAsFixed(2)),
                          ),
                          DataCell(Text(result.throughput.toStringAsFixed(2))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBestAlgorithmView() {
    final bestTAT = _findBestAlgorithm(_getTurnaroundTimes());
    final bestWT = _findBestAlgorithm(_getWaitingTimes());
    final bestRT = _findBestAlgorithm(_getResponseTimes());
    final bestCPU = _findBestAlgorithmMax(_getCpuUtilizations());

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Best Performing Algorithms',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildBestAlgorithmCard(
                  'Lowest Turnaround Time',
                  _algorithmNames[bestTAT.index],
                  bestTAT.value.toStringAsFixed(2),
                  Icons.timer,
                  Colors.green,
                ),
                _buildBestAlgorithmCard(
                  'Lowest Waiting Time',
                  _algorithmNames[bestWT.index],
                  bestWT.value.toStringAsFixed(2),
                  Icons.hourglass_empty,
                  Colors.blue,
                ),
                _buildBestAlgorithmCard(
                  'Lowest Response Time',
                  _algorithmNames[bestRT.index],
                  bestRT.value.toStringAsFixed(2),
                  Icons.speed,
                  Colors.orange,
                ),
                _buildBestAlgorithmCard(
                  'Highest CPU Utilization',
                  _algorithmNames[bestCPU.index],
                  '${bestCPU.value.toStringAsFixed(2)}%',
                  Icons.memory,
                  Colors.purple,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildOverallRecommendation(),
        ],
      ),
    );
  }

  Widget _buildBestAlgorithmCard(
    String title,
    String algorithm,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              algorithm,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallRecommendation() {
    // Calculate overall best algorithm based on weighted score
    final scores = List<double>.filled(_algorithmNames.length, 0);

    final tatValues = _getTurnaroundTimes();
    final wtValues = _getWaitingTimes();
    final rtValues = _getResponseTimes();

    for (int i = 0; i < _algorithmNames.length; i++) {
      // Lower is better for TAT, WT, RT (inverse scoring)
      final maxTAT = tatValues.reduce((a, b) => a > b ? a : b);
      final maxWT = wtValues.reduce((a, b) => a > b ? a : b);
      final maxRT = rtValues.reduce((a, b) => a > b ? a : b);

      scores[i] =
          (maxTAT - tatValues[i]) / maxTAT * 0.4 +
          (maxWT - wtValues[i]) / maxWT * 0.4 +
          (maxRT - rtValues[i]) / maxRT * 0.2;
    }

    final bestOverall = _findBestAlgorithmMax(scores);

    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.emoji_events, size: 48, color: Colors.amber),
            const SizedBox(height: 8),
            const Text(
              'Overall Best Algorithm',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _algorithmNames[bestOverall.index],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Based on weighted average of TAT (40%), WT (40%), and RT (20%)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<double> _getTurnaroundTimes() {
    return widget.results.map((r) => r.averageTurnaroundTime).toList();
  }

  List<double> _getWaitingTimes() {
    return widget.results.map((r) => r.averageWaitingTime).toList();
  }

  List<double> _getResponseTimes() {
    return widget.results.map((r) => r.averageResponseTime).toList();
  }

  List<double> _getCpuUtilizations() {
    return widget.results.map((r) => r.cpuUtilization).toList();
  }

  ({int index, double value}) _findBestAlgorithm(List<double> values) {
    double minValue = values[0];
    int minIndex = 0;

    for (int i = 1; i < values.length; i++) {
      if (values[i] < minValue) {
        minValue = values[i];
        minIndex = i;
      }
    }

    return (index: minIndex, value: minValue);
  }

  ({int index, double value}) _findBestAlgorithmMax(List<double> values) {
    double maxValue = values[0];
    int maxIndex = 0;

    for (int i = 1; i < values.length; i++) {
      if (values[i] > maxValue) {
        maxValue = values[i];
        maxIndex = i;
      }
    }

    return (index: maxIndex, value: maxValue);
  }

  Color _getBarColor(int index) {
    const colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }
}
