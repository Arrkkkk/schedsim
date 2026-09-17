import 'dart:math';
import '../models/mlq_process.dart';
import '../models/gantt_segment.dart';
import '../models/schedule_result.dart';

class MLQScheduling {
  // Queue configurations
  static const Map<int, Map<String, dynamic>> queueConfigs = {
    1: {
      'name': 'Q1 (Interactive)',
      'algorithm': 'Round Robin',
      'timeQuantum': 4,
      'priority': 1, // Highest priority
    },
    2: {
      'name': 'Q2 (Batch)',
      'algorithm': 'FCFS',
      'timeQuantum': null,
      'priority': 2,
    },
    3: {
      'name': 'Q3 (Background)',
      'algorithm': 'FCFS',
      'timeQuantum': null,
      'priority': 3, // Lowest priority
    },
  };

  static ScheduleResult schedule(List<MLQProcess> processes) {
    final ganttChart = <GanttSegment>[];
    final steps = <String>['MLQ Algorithm - Multi-Level Queue Scheduling'];
    
    // Group processes by queue
    final Map<int, List<MLQProcess>> queueGroups = {};
    for (final process in processes) {
      queueGroups.putIfAbsent(process.queue, () => []).add(process);
    }

    steps.add('Processes grouped by queue:');
    for (final entry in queueGroups.entries) {
      final queueNum = entry.key;
      final queueProcesses = entry.value;
      final config = queueConfigs[queueNum]!;
      
      steps.add('${config['name']} (Priority ${config['priority']}):');
      for (final process in queueProcesses) {
        steps.add('  ${process.id}: Arrival=${process.arrivalTime}, Burst=${process.burstTime}');
      }
    }

    int currentTime = 0;

    // Process queues in priority order (1, 2, 3, ...)
    final sortedQueues = queueGroups.keys.toList()..sort();
    
    for (final queueNum in sortedQueues) {
      final queueProcesses = queueGroups[queueNum]!;
      final config = queueConfigs[queueNum]!;
      
      if (queueProcesses.isEmpty) continue;
      
      steps.add('\nProcessing ${config['name']} with ${config['algorithm']}...');
      
      if (config['algorithm'] == 'Round Robin') {
        currentTime = _processRoundRobinQueue(
          queueProcesses, 
          ganttChart, 
          steps, 
          currentTime, 
          config['timeQuantum']
        );
      } else if (config['algorithm'] == 'FCFS') {
        currentTime = _processFCFSQueue(
          queueProcesses, 
          ganttChart, 
          steps, 
          currentTime
        );
      }
    }

    return _calculateMetrics(processes, ganttChart, steps);
  }

  static int _processRoundRobinQueue(
    List<MLQProcess> processes,
    List<GanttSegment> ganttChart,
    List<String> steps,
    int startTime,
    int timeQuantum,
  ) {
    // Sort by arrival time
    final sortedProcesses = [...processes]
      ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    
    final readyQueue = <MLQProcess>[];
    int currentTime = startTime;
    int processIndex = 0;

    steps.add('Round Robin with time quantum = ${timeQuantum}ms');

    while (processIndex < sortedProcesses.length || readyQueue.isNotEmpty) {
      // Add processes that have arrived
      while (processIndex < sortedProcesses.length && 
             sortedProcesses[processIndex].arrivalTime <= currentTime) {
        readyQueue.add(sortedProcesses[processIndex]);
        processIndex++;
      }

      if (readyQueue.isEmpty) {
        // No processes ready, advance time to next arrival
        if (processIndex < sortedProcesses.length) {
          currentTime = sortedProcesses[processIndex].arrivalTime;
        }
        continue;
      }

      final currentProcess = readyQueue.removeAt(0);
      
      if (!currentProcess.hasStarted) {
        currentProcess.hasStarted = true;
        currentProcess.responseTime = currentTime - currentProcess.arrivalTime;
        currentProcess.firstResponseTime = currentTime;
      }

      final executionTime = min(currentProcess.remainingTime, timeQuantum);
      final startTime = currentTime;
      final endTime = startTime + executionTime;

      ganttChart.add(
        GanttSegment(
          processId: currentProcess.id,
          startTime: startTime,
          endTime: endTime,
        ),
      );

      currentProcess.remainingTime -= executionTime;
      currentTime = endTime;

      steps.add(
        '${currentProcess.id}: Start=$startTime, End=$endTime, Remaining=${currentProcess.remainingTime}'
      );

      if (currentProcess.remainingTime > 0) {
        // Process not finished, add back to queue
        readyQueue.add(currentProcess);
      } else {
        // Process completed
        currentProcess.completionTime = endTime;
        currentProcess.turnaroundTime = currentProcess.completionTime - currentProcess.arrivalTime;
        currentProcess.waitingTime = currentProcess.turnaroundTime - currentProcess.burstTime;
      }
    }

    return currentTime;
  }

  static int _processFCFSQueue(
    List<MLQProcess> processes,
    List<GanttSegment> ganttChart,
    List<String> steps,
    int startTime,
  ) {
    // Sort by arrival time
    final sortedProcesses = [...processes]
      ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    
    int currentTime = startTime;

    steps.add('FCFS (First Come First Serve)');

    for (final process in sortedProcesses) {
      if (currentTime < process.arrivalTime) {
        currentTime = process.arrivalTime;
      }

      final startTime = currentTime;
      final endTime = startTime + process.burstTime;

      process.completionTime = endTime;
      process.turnaroundTime = process.completionTime - process.arrivalTime;
      process.waitingTime = process.turnaroundTime - process.burstTime;
      process.responseTime = startTime - process.arrivalTime;
      process.hasStarted = true;
      process.firstResponseTime = startTime;

      ganttChart.add(
        GanttSegment(
          processId: process.id,
          startTime: startTime,
          endTime: endTime,
        ),
      );

      steps.add(
        '${process.id}: Start=$startTime, End=$endTime, TAT=${process.turnaroundTime}, WT=${process.waitingTime}'
      );
      currentTime = endTime;
    }

    return currentTime;
  }

  static ScheduleResult _calculateMetrics(
    List<MLQProcess> processes,
    List<GanttSegment> ganttChart,
    List<String> steps,
  ) {
    final totalProcesses = processes.length;
    final totalTurnaroundTime = processes.fold<int>(
      0,
      (sum, process) => sum + process.turnaroundTime,
    );
    final totalWaitingTime = processes.fold<int>(
      0,
      (sum, process) => sum + process.waitingTime,
    );
    final totalResponseTime = processes.fold<int>(
      0,
      (sum, process) => sum + process.responseTime,
    );

    final avgTurnaroundTime = totalTurnaroundTime / totalProcesses;
    final avgWaitingTime = totalWaitingTime / totalProcesses;
    final avgResponseTime = totalResponseTime / totalProcesses;

    steps.add('\n=== MLQ Scheduling Results ===');
    steps.add('Average Turnaround Time: ${avgTurnaroundTime.toStringAsFixed(2)}');
    steps.add('Average Waiting Time: ${avgWaitingTime.toStringAsFixed(2)}');
    steps.add('Average Response Time: ${avgResponseTime.toStringAsFixed(2)}');

    // Add queue-specific results
    final Map<int, List<MLQProcess>> queueGroups = {};
    for (final process in processes) {
      queueGroups.putIfAbsent(process.queue, () => []).add(process);
    }

    for (final entry in queueGroups.entries) {
      final queueNum = entry.key;
      final queueProcesses = entry.value;
      final config = queueConfigs[queueNum]!;
      
      final queueAvgTAT = queueProcesses.fold<int>(0, (sum, p) => sum + p.turnaroundTime) / queueProcesses.length;
      final queueAvgWT = queueProcesses.fold<int>(0, (sum, p) => sum + p.waitingTime) / queueProcesses.length;
      
      steps.add('${config['name']} - Avg TAT: ${queueAvgTAT.toStringAsFixed(2)}, Avg WT: ${queueAvgWT.toStringAsFixed(2)}');
    }

    return ScheduleResult(
      cpuUtilization: 100.0,
      throughput: processes.length / (ganttChart.isNotEmpty ? ganttChart.last.endTime / 1000.0 : 1.0),
      processes: processes.map((p) => p.toProcess()).toList(),
      ganttChart: ganttChart,
      averageTurnaroundTime: avgTurnaroundTime,
      averageWaitingTime: avgWaitingTime,
      averageResponseTime: avgResponseTime,
      steps: steps,
    );
  }

  // Helper method to create example MLQ processes
  static List<MLQProcess> createExampleProcesses() {
    return [
      MLQProcess(id: 'P1', arrivalTime: 0, burstTime: 5, priority: 1, queue: 1),
      MLQProcess(id: 'P2', arrivalTime: 1, burstTime: 3, priority: 2, queue: 2),
      MLQProcess(id: 'P3', arrivalTime: 2, burstTime: 8, priority: 3, queue: 3),
      MLQProcess(id: 'P4', arrivalTime: 3, burstTime: 6, priority: 1, queue: 1),
    ];
  }
}
