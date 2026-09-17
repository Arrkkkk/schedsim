import 'package:flutter_test/flutter_test.dart';
import 'package:schedsim/services/scheduling_algorithms.dart';
import 'package:schedsim/models/process.dart';

void main() {
  test('Debug Gantt Chart with Image Data', () {
    // Process data from the image - exact values shown
    final processes = [
      Process(id: 'P1', arrivalTime: 9, burstTime: 2, priority: 8),
      Process(id: 'P2', arrivalTime: 2, burstTime: 6, priority: 5),
      Process(id: 'P3', arrivalTime: 3, burstTime: 15, priority: 4),
      Process(id: 'P4', arrivalTime: 2, burstTime: 10, priority: 7),
      Process(id: 'P5', arrivalTime: 5, burstTime: 14, priority: 1),
    ];

    print('=== FCFS Algorithm Debug ===');
    print('Input processes:');
    for (final process in processes) {
      print('  ${process.id}: AT=${process.arrivalTime}, BT=${process.burstTime}, Priority=${process.priority}');
    }

    final fcfsResult = SchedulingAlgorithms.fcfs(processes);
    print('\nFCFS Gantt Chart segments:');
    for (final segment in fcfsResult.ganttChart) {
      print('  ${segment.processId}: ${segment.startTime}-${segment.endTime} (duration: ${segment.duration})');
    }

    print('\nProcess completion times:');
    for (final process in fcfsResult.processes) {
      print('  ${process.id}: CT=${process.completionTime}, TAT=${process.turnaroundTime}, WT=${process.waitingTime}');
    }

    // Verify all processes are included
    final processIds = fcfsResult.ganttChart.map((s) => s.processId).toSet();
    final expectedIds = processes.map((p) => p.id).toSet();
    
    print('\nProcess verification:');
    print('  Processes in Gantt chart: $processIds');
    print('  Expected processes: $expectedIds');
    print('  All processes present: ${processIds.containsAll(expectedIds)}');
    
    // Check for gaps in timeline
    print('\nTimeline analysis:');
    int expectedTime = 0;
    for (int i = 0; i < fcfsResult.ganttChart.length; i++) {
      final segment = fcfsResult.ganttChart[i];
      if (segment.startTime > expectedTime) {
        print('  GAP: Time ${expectedTime} to ${segment.startTime} is idle');
      }
      print('  ${segment.processId}: ${segment.startTime}-${segment.endTime}');
      expectedTime = segment.endTime;
    }

    // Verify FCFS order (should be sorted by arrival time)
    final sortedByArrival = [...processes]..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    print('\nFCFS order verification:');
    print('  Expected order by arrival time: ${sortedByArrival.map((p) => p.id).join(' -> ')}');
    print('  Actual Gantt order: ${fcfsResult.ganttChart.map((s) => s.processId).join(' -> ')}');
    
    // Check if the order matches FCFS
    bool orderCorrect = true;
    for (int i = 0; i < fcfsResult.ganttChart.length; i++) {
      if (fcfsResult.ganttChart[i].processId != sortedByArrival[i].id) {
        orderCorrect = false;
        break;
      }
    }
    print('  FCFS order correct: $orderCorrect');

    // Test with a simple case
    print('\n=== Simple FCFS Test ===');
    final simpleProcesses = [
      Process(id: 'A', arrivalTime: 0, burstTime: 3, priority: 1),
      Process(id: 'B', arrivalTime: 1, burstTime: 2, priority: 2),
      Process(id: 'C', arrivalTime: 2, burstTime: 1, priority: 3),
    ];
    
    final simpleResult = SchedulingAlgorithms.fcfs(simpleProcesses);
    print('Simple FCFS segments:');
    for (final segment in simpleResult.ganttChart) {
      print('  ${segment.processId}: ${segment.startTime}-${segment.endTime}');
    }
  });
}
