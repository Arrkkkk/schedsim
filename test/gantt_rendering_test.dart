import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schedsim/widgets/gantt_chart_widget.dart';
import 'package:schedsim/models/schedule_result.dart';
import 'package:schedsim/models/gantt_segment.dart';
import 'package:schedsim/models/process.dart';

void main() {
  testWidgets('Gantt Chart Rendering Test', (WidgetTester tester) async {
    // Create test data with multiple processes
    final segments = [
      GanttSegment(processId: 'P2', startTime: 2, endTime: 16),
      GanttSegment(processId: 'P5', startTime: 16, endTime: 24),
      GanttSegment(processId: 'P3', startTime: 24, endTime: 34),
      GanttSegment(processId: 'P1', startTime: 34, endTime: 39),
      GanttSegment(processId: 'P4', startTime: 39, endTime: 43),
    ];

    final processes = [
      Process(id: 'P1', arrivalTime: 6, burstTime: 5, priority: 1),
      Process(id: 'P2', arrivalTime: 2, burstTime: 14, priority: 1),
      Process(id: 'P3', arrivalTime: 4, burstTime: 10, priority: 2),
      Process(id: 'P4', arrivalTime: 6, burstTime: 4, priority: 2),
      Process(id: 'P5', arrivalTime: 2, burstTime: 8, priority: 2),
    ];

    final result = ScheduleResult(
      processes: processes,
      ganttChart: segments,
      averageTurnaroundTime: 20.0,
      averageWaitingTime: 10.0,
      averageResponseTime: 5.0,
      cpuUtilization: 80.0,
      throughput: 0.1,
      steps: ['Test steps'],
    );

    // Test the Gantt chart widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttChartWidget(result: result),
        ),
      ),
    );

    // Verify that the Gantt chart is displayed
    expect(find.text('Gantt Chart'), findsOneWidget);
    
    // Verify that all process IDs are visible in the legend
    expect(find.text('P1'), findsWidgets);
    expect(find.text('P2'), findsWidgets);
    expect(find.text('P3'), findsWidgets);
    expect(find.text('P4'), findsWidgets);
    expect(find.text('P5'), findsWidgets);

    // Verify the legend shows all processes
    final legendCard = find.byType(Card);
    expect(legendCard, findsOneWidget);
  });

  testWidgets('Gantt Chart with Preemptive Segments', (WidgetTester tester) async {
    // Create test data with preemptive segments
    final segments = [
      GanttSegment(processId: 'P5', startTime: 2, endTime: 6, isPreempted: true),
      GanttSegment(processId: 'P4', startTime: 6, endTime: 10, isPreempted: false),
      GanttSegment(processId: 'P5', startTime: 10, endTime: 14, isPreempted: false),
      GanttSegment(processId: 'P1', startTime: 14, endTime: 19, isPreempted: false),
      GanttSegment(processId: 'P3', startTime: 19, endTime: 29, isPreempted: false),
      GanttSegment(processId: 'P2', startTime: 29, endTime: 43, isPreempted: false),
    ];

    final processes = [
      Process(id: 'P1', arrivalTime: 6, burstTime: 5, priority: 1),
      Process(id: 'P2', arrivalTime: 2, burstTime: 14, priority: 1),
      Process(id: 'P3', arrivalTime: 4, burstTime: 10, priority: 2),
      Process(id: 'P4', arrivalTime: 6, burstTime: 4, priority: 2),
      Process(id: 'P5', arrivalTime: 2, burstTime: 8, priority: 2),
    ];

    final result = ScheduleResult(
      processes: processes,
      ganttChart: segments,
      averageTurnaroundTime: 20.0,
      averageWaitingTime: 10.0,
      averageResponseTime: 5.0,
      cpuUtilization: 80.0,
      throughput: 0.1,
      steps: ['Test steps'],
    );

    // Test the Gantt chart widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GanttChartWidget(result: result),
        ),
      ),
    );

    // Verify that the Gantt chart is displayed
    expect(find.text('Gantt Chart'), findsOneWidget);
    
    // Verify that all process IDs are visible
    expect(find.text('P1'), findsWidgets);
    expect(find.text('P2'), findsWidgets);
    expect(find.text('P3'), findsWidgets);
    expect(find.text('P4'), findsWidgets);
    expect(find.text('P5'), findsWidgets);
  });
}
