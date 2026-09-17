import 'package:flutter_test/flutter_test.dart';
import 'package:schedsim/services/scheduling_algorithms.dart';
import 'package:schedsim/models/process.dart';

void main() {
  group('Scheduling Algorithms Gantt Chart Tests', () {
    test('FCFS Algorithm generates correct Gantt chart', () {
      final processes = [
        Process(id: 'P1', arrivalTime: 0, burstTime: 3, priority: 1),
        Process(id: 'P2', arrivalTime: 1, burstTime: 2, priority: 2),
        Process(id: 'P3', arrivalTime: 2, burstTime: 1, priority: 3),
      ];

      final result = SchedulingAlgorithms.fcfs(processes);

      expect(result.ganttChart.length, equals(3));
      expect(result.ganttChart[0].processId, equals('P1'));
      expect(result.ganttChart[0].startTime, equals(0));
      expect(result.ganttChart[0].endTime, equals(3));
      expect(result.ganttChart[1].processId, equals('P2'));
      expect(result.ganttChart[1].startTime, equals(3));
      expect(result.ganttChart[1].endTime, equals(5));
      expect(result.ganttChart[2].processId, equals('P3'));
      expect(result.ganttChart[2].startTime, equals(5));
      expect(result.ganttChart[2].endTime, equals(6));
    });

    test('SJF Non-Preemptive Algorithm generates correct Gantt chart', () {
      final processes = [
        Process(id: 'P1', arrivalTime: 0, burstTime: 3, priority: 1),
        Process(id: 'P2', arrivalTime: 1, burstTime: 1, priority: 2),
        Process(id: 'P3', arrivalTime: 2, burstTime: 2, priority: 3),
      ];

      final result = SchedulingAlgorithms.sjfNonPreemptive(processes);

      expect(result.ganttChart.length, equals(3));
      expect(result.ganttChart[0].processId, equals('P1'));
      expect(result.ganttChart[0].startTime, equals(0));
      expect(result.ganttChart[0].endTime, equals(3));
      expect(result.ganttChart[1].processId, equals('P2'));
      expect(result.ganttChart[1].startTime, equals(3));
      expect(result.ganttChart[1].endTime, equals(4));
      expect(result.ganttChart[2].processId, equals('P3'));
      expect(result.ganttChart[2].startTime, equals(4));
      expect(result.ganttChart[2].endTime, equals(6));
    });

    test('Round Robin Algorithm generates correct Gantt chart', () {
      final processes = [
        Process(id: 'P1', arrivalTime: 0, burstTime: 4, priority: 1),
        Process(id: 'P2', arrivalTime: 1, burstTime: 3, priority: 2),
      ];

      final result = SchedulingAlgorithms.roundRobin(processes, 2);

      expect(result.ganttChart.length, greaterThan(0));
      expect(result.ganttChart.first.startTime, equals(0));
      expect(result.ganttChart.last.endTime, equals(7));
    });

    test('SJF Preemptive Algorithm generates correct Gantt chart', () {
      final processes = [
        Process(id: 'P1', arrivalTime: 0, burstTime: 4, priority: 1),
        Process(id: 'P2', arrivalTime: 1, burstTime: 2, priority: 2),
      ];

      final result = SchedulingAlgorithms.sjfPreemptive(processes);

      expect(result.ganttChart.length, greaterThan(0));
      expect(result.ganttChart.first.startTime, equals(0));
      expect(result.ganttChart.last.endTime, equals(6));
    });
  });
}
