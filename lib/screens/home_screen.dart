import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../widgets/app_info_dialog.dart';
import 'algorithm_screen.dart';
import 'mlq_algorithm_screen_v2.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('CPU Scheduling Simulator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => AppInfoDialog.show(context),
            tooltip: 'App Info',
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select a Scheduling Algorithm',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Make grid responsive based on screen width
                        int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                        double childAspectRatio = constraints.maxWidth > 600 ? 1.3 : 1.0;
                        
                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: childAspectRatio,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: [
                            _AlgorithmCard(
                              title: 'FCFS',
                              subtitle: 'First Come First Serve',
                              icon: Icons.queue,
                              onTap: () => _navigateToAlgorithm(context, 'FCFS'),
                            ),
                            _AlgorithmCard(
                              title: 'SJF',
                              subtitle: 'Shortest Job First',
                              icon: Icons.schedule,
                              onTap: () => _navigateToAlgorithm(context, 'SJF'),
                            ),
                            _AlgorithmCard(
                              title: 'SRTF',
                              subtitle: 'Shortest Remaining Time First',
                              icon: Icons.timer,
                              onTap: () => _navigateToAlgorithm(context, 'SRTF'),
                            ),
                            _AlgorithmCard(
                              title: 'Round Robin',
                              subtitle: 'Time Quantum Based',
                              icon: Icons.rotate_right,
                              onTap: () => _navigateToAlgorithm(context, 'RR'),
                            ),
                            _AlgorithmCard(
                              title: 'Priority',
                              subtitle: 'Priority Based',
                              icon: Icons.star,
                              onTap: () => _navigateToAlgorithm(context, 'Priority'),
                            ),
                            _AlgorithmCard(
                              title: 'MLQ',
                              subtitle: 'Multilevel Queue',
                              icon: Icons.layers,
                              onTap: () => _navigateToAlgorithm(context, 'MLQ'),
                            ),
                            _AlgorithmCard(
                              title: 'MLFQ',
                              subtitle: 'Multilevel Feedback Queue',
                              icon: Icons.layers_outlined,
                              onTap: () => _navigateToAlgorithm(context, 'MLFQ'),
                            ),
                            _AlgorithmCard(
                              title: 'Compare All',
                              subtitle: 'Side-by-side Analysis',
                              icon: Icons.compare_arrows,
                              onTap: () => _navigateToAlgorithm(context, 'Compare'),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Copyright footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
            ),
            child: Text(
              '© 2025 CPU Scheduling Simulator • Created with Flutter',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToAlgorithm(BuildContext context, String algorithm) {
    if (algorithm == 'MLQ') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MLQAlgorithmScreenV2(),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AlgorithmScreen(algorithm: algorithm),
      ),
    );
  }
}

class _AlgorithmCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _AlgorithmCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      elevation: 4,
      color: isDark ? Colors.grey[850] : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Make padding and icon size responsive
            double padding = constraints.maxWidth < 150 ? 8.0 : 12.0;
            double iconSize = constraints.maxWidth < 150 ? 28.0 : 36.0;
            
            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Icon(
                      icon, 
                      size: iconSize, 
                      color: isDark ? Colors.white : Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight < 120 ? 4 : 6),
                  Flexible(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: constraints.maxWidth < 150 ? 14 : null,
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight < 120 ? 2 : 4),
                  Flexible(
                    child: Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: constraints.maxWidth < 150 ? 12 : null,
                        color: isDark ? Colors.grey[300] : Colors.grey[600],
                      ),
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
      ),
    );
  }
}
