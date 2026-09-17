import 'package:flutter/material.dart';
import '../models/schedule_result.dart';

class ResultsTableWidget extends StatelessWidget {
  final ScheduleResult result;

  const ResultsTableWidget({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Results Table',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildProcessTable(context),
            const SizedBox(height: 24),
            _buildSummaryCards(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessTable(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Process Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Process')),
                  DataColumn(label: Text('AT')),
                  DataColumn(label: Text('BT')),
                  DataColumn(label: Text('CT')),
                  DataColumn(label: Text('TAT')),
                  DataColumn(label: Text('WT')),
                  DataColumn(label: Text('RT')),
                ],
                rows: result.processes.map((process) {
                  return DataRow(
                    cells: [
                      DataCell(Text(process.id)),
                      DataCell(Text(process.arrivalTime.toString())),
                      DataCell(Text(process.burstTime.toString())),
                      DataCell(Text(process.completionTime.toString())),
                      DataCell(Text(process.turnaroundTime.toString())),
                      DataCell(Text(process.waitingTime.toString())),
                      DataCell(Text(process.responseTime.toString())),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _buildTableLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildTableLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: const [
        Text(
          'AT: Arrival Time',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          'BT: Burst Time',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          'CT: Completion Time',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          'TAT: Turnaround Time',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          'WT: Waiting Time',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          'RT: Response Time',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Metrics',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // Make grid responsive based on screen width
            int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
            double childAspectRatio = constraints.maxWidth > 600 ? 2.2 : 1.6;

            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildMetricCard(
                  'Average TAT',
                  result.averageTurnaroundTime,
                  Icons.timer,
                ),
                _buildMetricCard(
                  'Average WT',
                  result.averageWaitingTime,
                  Icons.hourglass_empty,
                ),
                _buildMetricCard(
                  'Average RT',
                  result.averageResponseTime,
                  Icons.speed,
                ),
                _buildMetricCard(
                  'CPU Utilization',
                  result.cpuUtilization,
                  Icons.memory,
                  suffix: '%',
                ),
                _buildMetricCard(
                  'Throughput',
                  result.throughput,
                  Icons.trending_up,
                  suffix: ' proc/time',
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    double value,
    IconData icon, {
    String suffix = '',
  }) {
    return Card(
      elevation: 2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Make padding and font sizes responsive
          double padding = constraints.maxWidth < 120 ? 6.0 : 10.0;
          double iconSize = constraints.maxWidth < 120 ? 16.0 : 20.0;
          double valueSize = constraints.maxWidth < 120 ? 12.0 : 14.0;
          double titleSize = constraints.maxWidth < 120 ? 9.0 : 11.0;

          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Icon(icon, size: iconSize, color: Colors.blue),
                ),
                SizedBox(height: constraints.maxHeight < 60 ? 2 : 4),
                Flexible(
                  child: Text(
                    '${value.toStringAsFixed(2)}$suffix',
                    style: TextStyle(
                      fontSize: valueSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: constraints.maxHeight < 60 ? 1 : 2),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: titleSize, color: Colors.grey),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
