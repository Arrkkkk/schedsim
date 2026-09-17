import 'package:flutter/material.dart';

class AppInfoDialog extends StatelessWidget {
  const AppInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text('App Information'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInfoSection(
              context,
              'About the App',
              'SchedSim is a CPU scheduling simulator for learning operating-system algorithms. Add processes, run a scheduler, and inspect Gantt charts, step-by-step traces, and waiting / turnaround / response metrics.',
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              context,
              'Features',
              '• FCFS, SJF, SRTF, Round Robin, Priority\n• Multilevel Queue (MLQ) and MLFQ\n• Interactive Gantt charts and step traces\n• Performance metrics and side-by-side comparison\n• Random process generation\n• Export results to PDF or CSV',
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              context,
              'Creator',
              'Developed by Rajit Agrawal\n\nA passionate software developer with expertise in mobile app development, algorithm visualization, and educational technology. This project demonstrates the power of Flutter in creating interactive learning experiences.',
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              context,
              'Technology Stack',
              '• Flutter Framework\n• Dart Programming Language\n• Riverpod State Management\n• Custom Paint for Visualizations\n• Material Design 3',
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              context,
              'Version',
              '1.0.0',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.4,
          ),
        ),
      ],
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AppInfoDialog();
      },
    );
  }
}
