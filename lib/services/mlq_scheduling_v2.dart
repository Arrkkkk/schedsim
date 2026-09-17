import 'dart:math';
import '../models/mlq_process.dart';
import '../models/mlq_queue_config.dart';
import '../models/gantt_segment.dart';
import '../models/schedule_result.dart';

class MLQSchedulingV2 {
  static ScheduleResult schedule(
    List<MLQProcess> processes,
    List<MLQQueueConfig> queueConfigs,
  ) {
    final ganttChart = <GanttSegment>[];
    print('MLQ Scheduling: Starting with ${processes.length} processes');
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
      final config = queueConfigs.firstWhere(
        (c) => c.queueNumber == queueNum,
        orElse: () => MLQQueueConfig(
          queueNumber: queueNum,
          name: 'Queue $queueNum',
          algorithm: 'FCFS',
          priority: queueNum,
        ),
      );
      
      steps.add('${config.name} (Priority ${config.priority}):');
      for (final process in queueProcesses) {
        steps.add('  ${process.id}: Arrival=${process.arrivalTime}, Burst=${process.burstTime}');
      }
    }

    int currentTime = 0;

    // Process queues in priority order
    final sortedQueues = queueGroups.keys.toList()..sort((a, b) {
      final configA = queueConfigs.firstWhere((c) => c.queueNumber == a);
      final configB = queueConfigs.firstWhere((c) => c.queueNumber == b);
      return configA.priority.compareTo(configB.priority);
    });
    
    for (final queueNum in sortedQueues) {
      final queueProcesses = queueGroups[queueNum]!;
      final config = queueConfigs.firstWhere((c) => c.queueNumber == queueNum);
      
      if (queueProcesses.isEmpty) continue;
      
      steps.add('\nProcessing ${config.name} with ${config.algorithm}...');
      
      switch (config.algorithm) {
        case 'Round Robin':
          currentTime = _processRoundRobinQueue(
            queueProcesses, 
            ganttChart, 
            steps, 
            currentTime, 
            config.timeQuantum ?? 4
          );
          break;
        case 'FCFS':
          currentTime = _processFCFSQueue(
            queueProcesses, 
            ganttChart, 
            steps, 
            currentTime
          );
          break;
        case 'SJF':
          currentTime = _processSJFQueue(
            queueProcesses, 
            ganttChart, 
            steps, 
            currentTime
          );
          break;
        case 'SRTF':
          currentTime = _processSRTFQueue(
            queueProcesses, 
            ganttChart, 
            steps, 
            currentTime
          );
          break;
        case 'Priority':
          currentTime = _processPriorityQueue(
            queueProcesses, 
            ganttChart, 
            steps, 
            currentTime
          );
          break;
        default:
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
    final sortedProcesses = [...processes]
      ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    
    final readyQueue = <MLQProcess>[];
    int currentTime = startTime;
    int processIndex = 0;

    steps.add('Round Robin with time quantum = ${timeQuantum}ms');

    while (processIndex < sortedProcesses.length || readyQueue.isNotEmpty) {
      while (processIndex < sortedProcesses.length && 
             sortedProcesses[processIndex].arrivalTime <= currentTime) {
        readyQueue.add(sortedProcesses[processIndex]);
        processIndex++;
      }

      if (readyQueue.isEmpty) {
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
        readyQueue.add(currentProcess);
      } else {
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

  static int _processSJFQueue(
    List<MLQProcess> processes,
    List<GanttSegment> ganttChart,
    List<String> steps,
    int startTime,
  ) {
    final sortedProcesses = [...processes]
      ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    
    final readyQueue = <MLQProcess>[];
    int currentTime = startTime;
    int processIndex = 0;

    steps.add('SJF (Shortest Job First)');

    while (processIndex < sortedProcesses.length || readyQueue.isNotEmpty) {
      while (processIndex < sortedProcesses.length && 
             sortedProcesses[processIndex].arrivalTime <= currentTime) {
        readyQueue.add(sortedProcesses[processIndex]);
        processIndex++;
      }

      if (readyQueue.isEmpty) {
        if (processIndex < sortedProcesses.length) {
          currentTime = sortedProcesses[processIndex].arrivalTime;
        }
        continue;
      }

      readyQueue.sort((a, b) => a.burstTime.compareTo(b.burstTime));
      final currentProcess = readyQueue.removeAt(0);
      
      if (!currentProcess.hasStarted) {
        currentProcess.hasStarted = true;
        currentProcess.responseTime = currentTime - currentProcess.arrivalTime;
        currentProcess.firstResponseTime = currentTime;
      }

      final startTime = currentTime;
      final endTime = startTime + currentProcess.burstTime;

      currentProcess.completionTime = endTime;
      currentProcess.turnaroundTime = currentProcess.completionTime - currentProcess.arrivalTime;
      currentProcess.waitingTime = currentProcess.turnaroundTime - currentProcess.burstTime;

      ganttChart.add(
        GanttSegment(
          processId: currentProcess.id,
          startTime: startTime,
          endTime: endTime,
        ),
      );

      steps.add(
        '${currentProcess.id}: Start=$startTime, End=$endTime, TAT=${currentProcess.turnaroundTime}, WT=${currentProcess.waitingTime}'
      );
      currentTime = endTime;
    }

    return currentTime;
  }

  static int _processSRTFQueue(
    List<MLQProcess> processes,
    List<GanttSegment> ganttChart,
    List<String> steps,
    int startTime,
  ) {
    final sortedProcesses = [...processes]
      ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    
    final readyQueue = <MLQProcess>[];
    int currentTime = startTime;
    int processIndex = 0;

    steps.add('SRTF (Shortest Remaining Time First)');

    while (processIndex < sortedProcesses.length || readyQueue.isNotEmpty) {
      while (processIndex < sortedProcesses.length && 
             sortedProcesses[processIndex].arrivalTime <= currentTime) {
        readyQueue.add(sortedProcesses[processIndex]);
        processIndex++;
      }

      if (readyQueue.isEmpty) {
        if (processIndex < sortedProcesses.length) {
          currentTime = sortedProcesses[processIndex].arrivalTime;
        }
        continue;
      }

      readyQueue.sort((a, b) => a.remainingTime.compareTo(b.remainingTime));
      final currentProcess = readyQueue.first;
      
      if (!currentProcess.hasStarted) {
        currentProcess.hasStarted = true;
        currentProcess.responseTime = currentTime - currentProcess.arrivalTime;
        currentProcess.firstResponseTime = currentTime;
      }

      final nextArrival = processIndex < sortedProcesses.length 
          ? sortedProcesses[processIndex].arrivalTime 
          : null;
      
      final executionTime = nextArrival != null 
          ? min(currentProcess.remainingTime, nextArrival - currentTime)
          : currentProcess.remainingTime;
      
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

      if (currentProcess.remainingTime <= 0) {
        readyQueue.remove(currentProcess);
        currentProcess.completionTime = endTime;
        currentProcess.turnaroundTime = currentProcess.completionTime - currentProcess.arrivalTime;
        currentProcess.waitingTime = currentProcess.turnaroundTime - currentProcess.burstTime;
      }
    }

    return currentTime;
  }

  static int _processPriorityQueue(
    List<MLQProcess> processes,
    List<GanttSegment> ganttChart,
    List<String> steps,
    int startTime,
  ) {
    final sortedProcesses = [...processes]
      ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    
    final readyQueue = <MLQProcess>[];
    int currentTime = startTime;
    int processIndex = 0;

    steps.add('Priority (Lower number = Higher priority)');

    while (processIndex < sortedProcesses.length || readyQueue.isNotEmpty) {
      while (processIndex < sortedProcesses.length && 
             sortedProcesses[processIndex].arrivalTime <= currentTime) {
        readyQueue.add(sortedProcesses[processIndex]);
        processIndex++;
      }

      if (readyQueue.isEmpty) {
        if (processIndex < sortedProcesses.length) {
          currentTime = sortedProcesses[processIndex].arrivalTime;
        }
        continue;
      }

      readyQueue.sort((a, b) => a.priority.compareTo(b.priority));
      final currentProcess = readyQueue.removeAt(0);
      
      if (!currentProcess.hasStarted) {
        currentProcess.hasStarted = true;
        currentProcess.responseTime = currentTime - currentProcess.arrivalTime;
        currentProcess.firstResponseTime = currentTime;
      }

      final startTime = currentTime;
      final endTime = startTime + currentProcess.burstTime;

      currentProcess.completionTime = endTime;
      currentProcess.turnaroundTime = currentProcess.completionTime - currentProcess.arrivalTime;
      currentProcess.waitingTime = currentProcess.turnaroundTime - currentProcess.burstTime;

      ganttChart.add(
        GanttSegment(
          processId: currentProcess.id,
          startTime: startTime,
          endTime: endTime,
        ),
      );

      steps.add(
        '${currentProcess.id}: Start=$startTime, End=$endTime, TAT=${currentProcess.turnaroundTime}, WT=${currentProcess.waitingTime}'
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

    return ScheduleResult(
      processes: processes.map((p) => p.toProcess()).toList(),
      ganttChart: ganttChart,
      averageTurnaroundTime: avgTurnaroundTime,
      averageWaitingTime: avgWaitingTime,
      averageResponseTime: avgResponseTime,
      cpuUtilization: 100.0,
      throughput: processes.length / (ganttChart.isNotEmpty ? ganttChart.last.endTime / 1000.0 : 1.0),
      steps: steps,
    );
  }
}
