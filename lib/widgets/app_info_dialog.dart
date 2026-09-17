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
              'CPU Scheduling Simulator is a comprehensive educational tool designed to help students and professionals understand various CPU scheduling algorithms through interactive visualizations and detailed analysis.',
            ),
            const SizedBox(height: 16),
            _buildInfoSection(
              context,
              'Features',
              '• First Come First Serve (FCFS)\n• Shortest Job First (SJF)\n• Shortest Remaining Time First (SRTF)\n• Round Robin Scheduling\n• Priority-based Scheduling\n• Interactive Gantt Charts\n• Performance Metrics Analysis\n• Side-by-side Algorithm Comparison',
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
