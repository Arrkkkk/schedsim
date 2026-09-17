import 'package:flutter/material.dart';
import '../models/schedule_result.dart';
import '../models/gantt_segment.dart';
import 'dart:math' as math;

class GanttChartWidget extends StatefulWidget {
  final ScheduleResult result;

  const GanttChartWidget({super.key, required this.result});

  @override
  State<GanttChartWidget> createState() => _GanttChartWidgetState();
}

class _GanttChartWidgetState extends State<GanttChartWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.result.ganttChart.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timeline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No Gantt Chart Data Available',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Run a simulation to see the Gantt chart',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gantt Chart', 
                style: Theme.of(context).textTheme.headlineSmall
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.zoom_out),
                    onPressed: () {
                      // Scroll to beginning
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    tooltip: 'Scroll to beginning',
                  ),
                  IconButton(
                    icon: const Icon(Icons.zoom_in),
                    onPressed: () {
                      // Scroll to end
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    tooltip: 'Scroll to end',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200, // Fixed height for the Gantt chart
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalTime = widget.result.ganttChart.last.endTime;
                final minSegmentWidth = 50.0; // Increased minimum width for better readability
                final calculatedWidth = math.max(
                  constraints.maxWidth,
                  totalTime * minSegmentWidth,
                );
                
                return SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    width: calculatedWidth,
                    height: constraints.maxHeight,
                    child: CustomPaint(
                      painter: GanttChartPainter(
                        widget.result.ganttChart,
                        totalTime: totalTime,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Scroll indicator
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
            child: AnimatedBuilder(
              animation: _scrollController,
              builder: (context, child) {
                if (!_scrollController.hasClients) return const SizedBox.shrink();
                
                final scrollPosition = _scrollController.offset;
                final maxScrollExtent = _scrollController.position.maxScrollExtent;
                
                // Calculate scroll percentage, ensuring it's between 0 and 1
                final scrollPercentage = maxScrollExtent > 0 
                    ? math.max(0.0, math.min(1.0, scrollPosition / maxScrollExtent))
                    : 0.0;
                
                // Calculate available width for the indicator
                final availableWidth = MediaQuery.of(context).size.width - 32; // Account for padding
                final indicatorWidth = 60.0;
                final maxIndicatorPosition = availableWidth - indicatorWidth;
                
                // Calculate the left margin position
                final leftMargin = math.max(0.0, scrollPercentage * maxIndicatorPosition);
                
                return Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Container(
                      width: indicatorWidth,
                      height: 4,
                      margin: EdgeInsets.only(left: leftMargin),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    final uniqueProcesses = widget.result.ganttChart
        .map((segment) => segment.processId)
        .toSet()
        .toList();

    if (uniqueProcesses.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          children: uniqueProcesses.map((processId) {
            final color = _getProcessColor(processId);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: color.withOpacity(0.5), width: 1),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  processId,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getProcessColor(String processId) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
      Colors.lightBlue,
      Colors.lightGreen,
    ];
    final hash = processId.hashCode;
    return colors[hash.abs() % colors.length];
  }
}

class GanttChartPainter extends CustomPainter {
  final List<GanttSegment> segments;
  final int totalTime;

  GanttChartPainter(this.segments, {required this.totalTime});

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty || totalTime <= 0) return;

    final paint = Paint();
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Calculate dimensions
    final segmentWidth = size.width / totalTime;
    final segmentHeight = math.min(60.0, size.height * 0.6);
    final yOffset = (size.height - segmentHeight) / 2;

    // Draw background
    paint.color = Colors.grey.shade100;
    canvas.drawRect(
      Rect.fromLTWH(0, yOffset, size.width, segmentHeight),
      paint,
    );

    // Draw grid lines
    paint.color = Colors.grey.shade300;
    paint.strokeWidth = 0.5;
    for (int i = 0; i <= totalTime; i++) {
      final x = i * segmentWidth;
      canvas.drawLine(
        Offset(x, yOffset),
        Offset(x, yOffset + segmentHeight),
        paint,
      );
    }

    // Draw segments
    for (final segment in segments) {
      final startX = segment.startTime * segmentWidth;
      final width = segment.duration * segmentWidth;
      final color = _getProcessColor(segment.processId);

      if (width > 0) {
        // Draw rectangle
        paint.color = color.withOpacity(0.8);
        paint.style = PaintingStyle.fill;
        canvas.drawRect(
          Rect.fromLTWH(startX, yOffset, width, segmentHeight),
          paint,
        );

        // Draw border
        paint.color = color;
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.5;
        canvas.drawRect(
          Rect.fromLTWH(startX, yOffset, width, segmentHeight),
          paint,
        );
        paint.style = PaintingStyle.fill;

        // Draw preemption indicator
        if (segment.isPreempted) {
          paint.color = Colors.red;
          paint.strokeWidth = 2;
          canvas.drawLine(
            Offset(startX + width - 1, yOffset),
            Offset(startX + width - 1, yOffset + segmentHeight),
            paint,
          );
        }

        // Draw process ID (only if segment is wide enough)
        if (width > 20) {
          textPainter.text = TextSpan(
            text: segment.processId,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: math.min(12, width / 3),
            ),
          );
          textPainter.layout();

          if (width > textPainter.width + 8) {
            textPainter.paint(
              canvas,
              Offset(
                startX + (width - textPainter.width) / 2,
                yOffset + (segmentHeight - textPainter.height) / 2,
              ),
            );
          }
        }
      }
    }

    // Draw time labels
    paint.color = Colors.grey.shade600;
    paint.strokeWidth = 1;
    
    for (int i = 0; i <= totalTime; i++) {
      final x = i * segmentWidth;
      
      // Draw vertical line
      canvas.drawLine(
        Offset(x, yOffset + segmentHeight),
        Offset(x, yOffset + segmentHeight + 8),
        paint,
      );

      // Draw time label
      textPainter.text = TextSpan(
        text: i.toString(),
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 10,
        ),
      );
      textPainter.layout();
      
      // Only draw label if there's enough space
      if (i == 0 || i == totalTime || (i % math.max(1, totalTime ~/ 10)) == 0) {
        // Calculate label position with proper bounds checking
        double labelX = x - textPainter.width / 2;
        
        // Ensure the label stays within the canvas bounds
        if (i == 0) {
          // For the first label (0), align it to the left edge
          labelX = math.max(0, x);
        } else if (i == totalTime) {
          // For the last label, align it to the right edge
          labelX = math.min(size.width - textPainter.width, x - textPainter.width / 2);
        } else {
          // For middle labels, center them but keep within bounds
          labelX = math.max(0, math.min(size.width - textPainter.width, x - textPainter.width / 2));
        }
        
        textPainter.paint(
          canvas,
          Offset(
            labelX,
            yOffset + segmentHeight + 12,
          ),
        );
      }
    }

    // Draw axis labels
    textPainter.text = TextSpan(
      text: 'Time',
      style: TextStyle(
        color: Colors.grey.shade700,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.width - textPainter.width - 5,
        yOffset + segmentHeight + 25,
      ),
    );
  }

  Color _getProcessColor(String processId) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
      Colors.lightBlue,
      Colors.lightGreen,
    ];
    final hash = processId.hashCode;
    return colors[hash.abs() % colors.length];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is GanttChartPainter) {
      return segments != oldDelegate.segments || totalTime != oldDelegate.totalTime;
    }
    return true;
  }
}
