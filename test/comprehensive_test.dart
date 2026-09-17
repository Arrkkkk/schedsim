import 'package:flutter_test/flutter_test.dart';
import 'package:schedsim/services/scheduling_algorithms.dart';
import 'package:schedsim/models/process.dart';

void main() {
  group('Comprehensive Scheduling Algorithm Tests', () {
    late List<Process> testProcesses;

    setUp(() {
      testProcesses = [
        Process(id: 'P1', arrivalTime: 0, burstTime: 4, priority: 3),
        Process(id: 'P2', arrivalTime: 1, burstTime: 2, priority: 1),
        Process(id: 'P3', arrivalTime: 2, burstTime: 3, priority: 2),
        Process(id: 'P4', arrivalTime: 3, burstTime: 1, priority: 4),
      ];
    });

    test('FCFS Algorithm - Complete Test', () {
      final result = SchedulingAlgorithms.fcfs(testProcesses);

      // Verify Gantt chart
      expect(result.ganttChart.length, equals(4));
      expect(result.ganttChart[0].processId, equals('P1'));
      expect(result.ganttChart[0].startTime, equals(0));
      expect(result.ganttChart[0].endTime, equals(4));
      expect(result.ganttChart[1].processId, equals('P2'));
      expect(result.ganttChart[1].startTime, equals(4));
      expect(result.ganttChart[1].endTime, equals(6));

      // Verify metrics
      expect(result.averageTurnaroundTime, greaterThan(0));
      expect(result.averageWaitingTime, greaterThanOrEqualTo(0));
      expect(result.cpuUtilization, greaterThan(0));
      expect(result.throughput, greaterThan(0));
    });

    test('SJF Non-Preemptive Algorithm - Complete Test', () {
      final result = SchedulingAlgorithms.sjfNonPreemptive(testProcesses);

      // Verify Gantt chart
      expect(result.ganttChart.length, equals(4));
      expect(result.ganttChart.first.startTime, equals(0));
      expect(result.ganttChart.last.endTime, equals(10));

      // Verify metrics
      expect(result.averageTurnaroundTime, greaterThan(0));
      expect(result.averageWaitingTime, greaterThanOrEqualTo(0));
      expect(result.cpuUtilization, greaterThan(0));
      expect(result.throughput, greaterThan(0));
    });

    test('SJF Preemptive Algorithm - Complete Test', () {
      final result = SchedulingAlgorithms.sjfPreemptive(testProcesses);

      // Verify Gantt chart
      expect(result.ganttChart.length, greaterThan(0));
      expect(result.ganttChart.first.startTime, equals(0));
      expect(result.ganttChart.last.endTime, equals(10));

      // Verify metrics
      expect(result.averageTurnaroundTime, greaterThan(0));
      expect(result.averageWaitingTime, greaterThanOrEqualTo(0));
      expect(result.cpuUtilization, greaterThan(0));
      expect(result.throughput, greaterThan(0));
    });

    test('Round Robin Algorithm - Complete Test', () {
      final result = SchedulingAlgorithms.roundRobin(testProcesses, 2);

      // Verify Gantt chart
      expect(result.ganttChart.length, greaterThan(0));
      expect(result.ganttChart.first.startTime, equals(0));
      expect(result.ganttChart.last.endTime, equals(10));

      // Verify metrics
      expect(result.averageTurnaroundTime, greaterThan(0));
      expect(result.averageWaitingTime, greaterThanOrEqualTo(0));
      expect(result.cpuUtilization, greaterThan(0));
      expect(result.throughput, greaterThan(0));
    });

    test('Priority Non-Preemptive Algorithm - Complete Test', () {
      final result = SchedulingAlgorithms.priorityNonPreemptive(testProcesses);

      // Verify Gantt chart
      expect(result.ganttChart.length, equals(4));
      expect(result.ganttChart.first.startTime, equals(0));
      expect(result.ganttChart.last.endTime, equals(10));

      // Verify metrics
      expect(result.averageTurnaroundTime, greaterThan(0));
      expect(result.averageWaitingTime, greaterThanOrEqualTo(0));
      expect(result.cpuUtilization, greaterThan(0));
      expect(result.throughput, greaterThan(0));
    });

    test('Priority Preemptive Algorithm - Complete Test', () {
      final result = SchedulingAlgorithms.priorityPreemptive(testProcesses);

      // Verify Gantt chart
      expect(result.ganttChart.length, greaterThan(0));
      expect(result.ganttChart.first.startTime, equals(0));
      expect(result.ganttChart.last.endTime, equals(10));

      // Verify metrics
      expect(result.averageTurnaroundTime, greaterThan(0));
      expect(result.averageWaitingTime, greaterThanOrEqualTo(0));
      expect(result.cpuUtilization, greaterThan(0));
      expect(result.throughput, greaterThan(0));
    });

    test('Gantt Chart Data Integrity', () {
      final algorithms = [
        () => SchedulingAlgorithms.fcfs(testProcesses),
        () => SchedulingAlgorithms.sjfNonPreemptive(testProcesses),
        () => SchedulingAlgorithms.sjfPreemptive(testProcesses),
        () => SchedulingAlgorithms.roundRobin(testProcesses, 2),
        () => SchedulingAlgorithms.priorityNonPreemptive(testProcesses),
        () => SchedulingAlgorithms.priorityPreemptive(testProcesses),
      ];

      for (final algorithm in algorithms) {
        final result = algorithm();
        
        // Verify Gantt chart data integrity
        expect(result.ganttChart.isNotEmpty, isTrue);
        
        // Verify segments are in chronological order
        for (int i = 1; i < result.ganttChart.length; i++) {
          expect(
            result.ganttChart[i].startTime, 
            greaterThanOrEqualTo(result.ganttChart[i-1].startTime)
          );
        }
        
        // Verify no negative durations
        for (final segment in result.ganttChart) {
          expect(segment.duration, greaterThan(0));
        }
        
        // Verify total time matches last segment end time
        expect(
          result.ganttChart.last.endTime, 
          equals(result.ganttChart.map((s) => s.endTime).reduce((a, b) => a > b ? a : b))
        );
      }
    });
  });
}
