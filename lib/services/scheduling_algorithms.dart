import 'dart:math';
import '../models/process.dart';
import '../models/gantt_segment.dart';
import '../models/schedule_result.dart';

class SchedulingAlgorithms {
  static ScheduleResult fcfs(List<Process> processes) {
    final sortedProcesses = [...processes]
      ..sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    final ganttChart = <GanttSegment>[];
    final steps = <String>['FCFS Algorithm - First Come First Serve'];

    int currentTime = 0;

    steps.add('Processes sorted by arrival time:');
    for (final process in sortedProcesses) {
      steps.add(
        '${process.id}: Arrival=${process.arrivalTime}, Burst=${process.burstTime}',
      );
    }

    for (final process in sortedProcesses) {
      if (currentTime < process.arrivalTime) {
        currentTime = process.arrivalTime;
      }

      final startTime = currentTime;
      final endTime = startTime + process.burstTime;

      process.completionTime = endTime;
      process.turnaroundTime = process.completionTime! - process.arrivalTime;
      process.waitingTime = process.turnaroundTime! - process.burstTime;
      process.responseTime = startTime - process.arrivalTime;

      ganttChart.add(
        GanttSegment(
          processId: process.id,
          startTime: startTime,
          endTime: endTime,
        ),
      );

      steps.add(
        '${process.id}: Start=$startTime, End=$endTime, TAT=${process.turnaroundTime}, WT=${process.waitingTime}',
      );
      currentTime = endTime;
    }

    return _calculateMetrics(sortedProcesses, ganttChart, steps);
  }

  static ScheduleResult sjfNonPreemptive(List<Process> processes) {
    final processList = processes.map((p) => p.copy()).toList();
    final ganttChart = <GanttSegment>[];
    final steps = <String>['SJF Non-Preemptive - Shortest Job First'];
    final completed = <Process>[];

    int currentTime = 0;

    while (completed.length < processList.length) {
      final availableProcesses = processList
          .where((p) => p.arrivalTime <= currentTime && !completed.contains(p))
          .toList();

      if (availableProcesses.isEmpty) {
        currentTime++;
        continue;
      }

      availableProcesses.sort((a, b) => a.burstTime.compareTo(b.burstTime));
      final selectedProcess = availableProcesses.first;

      final startTime = currentTime;
      final endTime = startTime + selectedProcess.burstTime;

      selectedProcess.completionTime = endTime;
      selectedProcess.turnaroundTime =
          selectedProcess.completionTime! - selectedProcess.arrivalTime;
      selectedProcess.waitingTime =
          selectedProcess.turnaroundTime! - selectedProcess.burstTime;
      selectedProcess.responseTime = startTime - selectedProcess.arrivalTime;

      ganttChart.add(
        GanttSegment(
          processId: selectedProcess.id,
          startTime: startTime,
          endTime: endTime,
        ),
      );

      steps.add(
        'Time $currentTime: Selected ${selectedProcess.id} (Burst=${selectedProcess.burstTime})',
      );
      completed.add(selectedProcess);
      currentTime = endTime;
    }

    return _calculateMetrics(processList, ganttChart, steps);
  }

  static ScheduleResult sjfPreemptive(List<Process> processes) {
    final processList = processes.map((p) => p.copy()).toList();
    final ganttChart = <GanttSegment>[];
    final steps = <String>[
      'SJF Preemptive (SRTF) - Shortest Remaining Time First',
    ];
    final completed = <Process>[];

    int currentTime = 0;
    Process? currentProcess;
    int processStartTime = 0;

    while (completed.length < processList.length) {
      final availableProcesses = processList
          .where((p) => p.arrivalTime <= currentTime && !completed.contains(p))
          .toList();

      if (availableProcesses.isEmpty) {
        if (currentProcess != null) {
          // If CPU is idle but a process was running, log its segment
          ganttChart.add(
            GanttSegment(
              processId: currentProcess.id,
              startTime: processStartTime,
              endTime: currentTime,
            ),
          );
          currentProcess = null; // CPU is now officially idle
        }
        currentTime++;
        continue;
      }

      availableProcesses.sort(
        (a, b) => a.remainingTime.compareTo(b.remainingTime),
      );
      final shortestProcess = availableProcesses.first;

      if (currentProcess != shortestProcess) {
        if (currentProcess != null) {
          ganttChart.add(
            GanttSegment(
              processId: currentProcess.id,
              startTime: processStartTime,
              endTime: currentTime,
              isPreempted: !completed.contains(currentProcess),
            ),
          );
        }

        currentProcess = shortestProcess;
        processStartTime = currentTime;

        if (!shortestProcess.hasStarted) {
          shortestProcess.hasStarted = true;
          shortestProcess.responseTime =
              currentTime - shortestProcess.arrivalTime;
        }

        steps.add(
          'Time $currentTime: Selected ${shortestProcess.id} (Remaining=${shortestProcess.remainingTime})',
        );
      }

      final activeProcess = currentProcess!;

      activeProcess.remainingTime--;
      currentTime++;

      if (activeProcess.remainingTime == 0) {
        activeProcess.completionTime = currentTime;
        activeProcess.turnaroundTime =
            activeProcess.completionTime! - activeProcess.arrivalTime;
        activeProcess.waitingTime =
            activeProcess.turnaroundTime! - activeProcess.burstTime;

        ganttChart.add(
          GanttSegment(
            processId: activeProcess.id,
            startTime: processStartTime,
            endTime: currentTime,
          ),
        );

        completed.add(activeProcess);
        currentProcess = null;
      }
    }

    return _calculateMetrics(processList, ganttChart, steps);
  }

  static ScheduleResult roundRobin(List<Process> processes, int quantum) {
    final processList = processes.map((p) => p.copy()).toList();
    final ganttChart = <GanttSegment>[];
    final steps = <String>['Round Robin Algorithm (Quantum = $quantum)'];
    final queue = <Process>[];
    final completed = <Process>[];

    int currentTime = 0;
    int processIndex = 0;

    processList.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    while (completed.length < processList.length) {
      while (processIndex < processList.length &&
          processList[processIndex].arrivalTime <= currentTime) {
        queue.add(processList[processIndex]);
        processIndex++;
      }

      if (queue.isEmpty) {
        currentTime++;
        continue;
      }

      final currentProcess = queue.removeAt(0);
      final startTime = currentTime;

      if (!currentProcess.hasStarted) {
        currentProcess.hasStarted = true;
        currentProcess.responseTime = startTime - currentProcess.arrivalTime;
      }

      final executionTime = min(quantum, currentProcess.remainingTime);
      currentProcess.remainingTime -= executionTime;
      currentTime += executionTime;

      ganttChart.add(
        GanttSegment(
          processId: currentProcess.id,
          startTime: startTime,
          endTime: currentTime,
          isPreempted: currentProcess.remainingTime > 0,
        ),
      );

      steps.add(
        'Time $startTime-$currentTime: ${currentProcess.id} executed (Remaining=${currentProcess.remainingTime})',
      );

      while (processIndex < processList.length &&
          processList[processIndex].arrivalTime <= currentTime) {
        queue.add(processList[processIndex]);
        processIndex++;
      }

      if (currentProcess.remainingTime > 0) {
        queue.add(currentProcess);
      } else {
        currentProcess.completionTime = currentTime;
        currentProcess.turnaroundTime =
            currentProcess.completionTime! - currentProcess.arrivalTime;
        currentProcess.waitingTime =
            currentProcess.turnaroundTime! - currentProcess.burstTime;
        completed.add(currentProcess);
      }
    }

    return _calculateMetrics(processList, ganttChart, steps);
  }

  static ScheduleResult priorityNonPreemptive(List<Process> processes) {
    final processList = processes.map((p) => p.copy()).toList();
    final ganttChart = <GanttSegment>[];
    final steps = <String>[
      'Priority Non-Preemptive (Lower number = Higher priority)',
    ];
    final completed = <Process>[];

    int currentTime = 0;

    while (completed.length < processList.length) {
      final availableProcesses = processList
          .where((p) => p.arrivalTime <= currentTime && !completed.contains(p))
          .toList();

      if (availableProcesses.isEmpty) {
        currentTime++;
        continue;
      }

      availableProcesses.sort((a, b) {
        final priorityComparison = a.priority.compareTo(b.priority);
        if (priorityComparison != 0) return priorityComparison;
        return a.arrivalTime.compareTo(b.arrivalTime);
      });

      final selectedProcess = availableProcesses.first;
      final startTime = currentTime;
      final endTime = startTime + selectedProcess.burstTime;

      selectedProcess.completionTime = endTime;
      selectedProcess.turnaroundTime =
          selectedProcess.completionTime! - selectedProcess.arrivalTime;
      selectedProcess.waitingTime =
          selectedProcess.turnaroundTime! - selectedProcess.burstTime;
      selectedProcess.responseTime = startTime - selectedProcess.arrivalTime;

      ganttChart.add(
        GanttSegment(
          processId: selectedProcess.id,
          startTime: startTime,
          endTime: endTime,
        ),
      );

      steps.add(
        'Time $currentTime: Selected ${selectedProcess.id} (Priority=${selectedProcess.priority})',
      );
      completed.add(selectedProcess);
      currentTime = endTime;
    }

    return _calculateMetrics(processList, ganttChart, steps);
  }

  static ScheduleResult priorityPreemptive(List<Process> processes) {
    final processList = processes.map((p) => p.copy()).toList();
    final ganttChart = <GanttSegment>[];
    final steps = <String>[
      'Priority Preemptive (Lower number = Higher priority)',
    ];
    final completed = <Process>[];

    int currentTime = 0;
    Process? currentProcess;
    int processStartTime = 0;

    while (completed.length < processList.length) {
      final availableProcesses = processList
          .where((p) => p.arrivalTime <= currentTime && !completed.contains(p))
          .toList();

      if (availableProcesses.isEmpty) {
        if (currentProcess != null) {
          ganttChart.add(
            GanttSegment(
              processId: currentProcess.id,
              startTime: processStartTime,
              endTime: currentTime,
            ),
          );
          currentProcess = null;
        }
        currentTime++;
        continue;
      }

      availableProcesses.sort((a, b) {
        final priorityComparison = a.priority.compareTo(b.priority);
        if (priorityComparison != 0) return priorityComparison;
        return a.arrivalTime.compareTo(b.arrivalTime);
      });

      final highestPriorityProcess = availableProcesses.first;

      if (currentProcess != highestPriorityProcess) {
        if (currentProcess != null) {
          ganttChart.add(
            GanttSegment(
              processId: currentProcess.id,
              startTime: processStartTime,
              endTime: currentTime,
              isPreempted: !completed.contains(currentProcess),
            ),
          );
        }

        currentProcess = highestPriorityProcess;
        processStartTime = currentTime;

        if (!currentProcess.hasStarted) {
          currentProcess.hasStarted = true;
          currentProcess.responseTime =
              currentTime - currentProcess.arrivalTime;
        }

        steps.add(
          'Time $currentTime: Selected ${currentProcess.id} (Priority=${currentProcess.priority})',
        );
      }

      final activeProcess = currentProcess!;

      activeProcess.remainingTime--;
      currentTime++;

      if (activeProcess.remainingTime == 0) {
        activeProcess.completionTime = currentTime;
        activeProcess.turnaroundTime =
            activeProcess.completionTime! - activeProcess.arrivalTime;
        activeProcess.waitingTime =
            activeProcess.turnaroundTime! - activeProcess.burstTime;

        ganttChart.add(
          GanttSegment(
            processId: activeProcess.id,
            startTime: processStartTime,
            endTime: currentTime,
          ),
        );

        completed.add(activeProcess);
        currentProcess = null;
      }
    }

    return _calculateMetrics(processList, ganttChart, steps);
  }

  // Multilevel Queue (MLQ) Scheduling Algorithm
  // Based on the PDF specification: System, Interactive, and Batch processes
  static ScheduleResult multilevelQueue(List<Process> processes) {
    final processList = processes.map((p) => p.copy()).toList();
    final ganttChart = <GanttSegment>[];
    final steps = <String>['Multilevel Queue (MLQ) Scheduling Algorithm'];
    
    // Define three queues based on process type/priority
    // System processes (Priority 0-2): Round Robin with Q=4
    // Interactive processes (Priority 3-5): Round Robin with Q=8  
    // Batch processes (Priority 6+): FCFS
    final systemQueue = <Process>[];
    final interactiveQueue = <Process>[];
    final batchQueue = <Process>[];
    final completed = <Process>[];

    int currentTime = 0;
    int processIndex = 0;

    processList.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    steps.add('MLQ Configuration:');
    steps.add('- System Queue (Priority 0-2): Round Robin with Q=4');
    steps.add('- Interactive Queue (Priority 3-5): Round Robin with Q=8');
    steps.add('- Batch Queue (Priority 6+): FCFS');
    steps.add('- Fixed Priority: System > Interactive > Batch');

    while (completed.length < processList.length) {
      // Add arriving processes to appropriate queues
      while (processIndex < processList.length &&
          processList[processIndex].arrivalTime <= currentTime) {
        final process = processList[processIndex];
        if (process.priority <= 2) {
          systemQueue.add(process);
          steps.add('Time $currentTime: ${process.id} added to System Queue (Priority=${process.priority})');
        } else if (process.priority <= 5) {
          interactiveQueue.add(process);
          steps.add('Time $currentTime: ${process.id} added to Interactive Queue (Priority=${process.priority})');
        } else {
          batchQueue.add(process);
          steps.add('Time $currentTime: ${process.id} added to Batch Queue (Priority=${process.priority})');
        }
        processIndex++;
      }

      Process? selectedProcess;
      String queueType = '';
      int quantum = 0;

      // Fixed priority scheduling: System > Interactive > Batch
      if (systemQueue.isNotEmpty) {
        selectedProcess = systemQueue.removeAt(0);
        queueType = 'System';
        quantum = 4; // Round Robin with Q=4
      } else if (interactiveQueue.isNotEmpty) {
        selectedProcess = interactiveQueue.removeAt(0);
        queueType = 'Interactive';
        quantum = 8; // Round Robin with Q=8
      } else if (batchQueue.isNotEmpty) {
        selectedProcess = batchQueue.removeAt(0);
        queueType = 'Batch';
        quantum = selectedProcess.remainingTime; // FCFS - run to completion
      }

      if (selectedProcess == null) {
        currentTime++;
        continue;
      }

      final startTime = currentTime;
      int executionTime;

      if (!selectedProcess.hasStarted) {
        selectedProcess.hasStarted = true;
        selectedProcess.responseTime = startTime - selectedProcess.arrivalTime;
      }

      // Execute based on queue type
      if (queueType == 'Batch') {
        // FCFS for batch processes
        executionTime = selectedProcess.remainingTime;
      } else {
        // Round Robin for system and interactive processes
        executionTime = min(quantum, selectedProcess.remainingTime);
      }

      selectedProcess.remainingTime -= executionTime;
      currentTime += executionTime;

      ganttChart.add(
        GanttSegment(
          processId: selectedProcess.id,
          startTime: startTime,
          endTime: currentTime,
          isPreempted: selectedProcess.remainingTime > 0 && queueType != 'Batch',
        ),
      );

      steps.add(
        'Time $startTime-$currentTime: ${selectedProcess.id} executed from $queueType Queue (Remaining=${selectedProcess.remainingTime})',
      );

      if (selectedProcess.remainingTime > 0) {
        // Re-add to appropriate queue if not completed (only for RR queues)
        if (queueType == 'System') {
          systemQueue.add(selectedProcess);
        } else if (queueType == 'Interactive') {
          interactiveQueue.add(selectedProcess);
        }
        // Batch processes run to completion (FCFS)
      } else {
        selectedProcess.completionTime = currentTime;
        selectedProcess.turnaroundTime =
            selectedProcess.completionTime! - selectedProcess.arrivalTime;
        selectedProcess.waitingTime =
            selectedProcess.turnaroundTime! - selectedProcess.burstTime;
        completed.add(selectedProcess);
      }
    }

    return _calculateMetrics(processList, ganttChart, steps);
  }

  // Multi Level Feedback Queue (MLFQ) Scheduling Algorithm
  // Based on the PDF specification with aging mechanism
  static ScheduleResult multilevelFeedbackQueue(List<Process> processes) {
    final processList = processes.map((p) => p.copy()).toList();
    final ganttChart = <GanttSegment>[];
    final steps = <String>['Multi Level Feedback Queue (MLFQ) Scheduling Algorithm'];
    
    // Create multiple queues with increasing time quantums
    // Q0: Quantum = 2, Q1: Quantum = 7, Q2: Quantum = 12, Q3: Quantum = 17, Q4: FCFS
    final queues = <List<Process>>[
      <Process>[], // Q0: Quantum = 2
      <Process>[], // Q1: Quantum = 7  
      <Process>[], // Q2: Quantum = 12
      <Process>[], // Q3: Quantum = 17
      <Process>[], // Q4: FCFS (no preemption)
    ];
    final quantums = [2, 7, 12, 17, 0]; // 0 means FCFS
    final completed = <Process>[];

    int currentTime = 0;
    int processIndex = 0;

    processList.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    steps.add('MLFQ Configuration:');
    steps.add('- Q0: Quantum = 2 (Highest Priority)');
    steps.add('- Q1: Quantum = 7');
    steps.add('- Q2: Quantum = 12');
    steps.add('- Q3: Quantum = 17');
    steps.add('- Q4: FCFS (Lowest Priority)');
    steps.add('- Processes start in Q0 and age down if they don\'t complete');

    while (completed.length < processList.length) {
      // Add arriving processes to highest priority queue (Q0)
      while (processIndex < processList.length &&
          processList[processIndex].arrivalTime <= currentTime) {
        queues[0].add(processList[processIndex]);
        steps.add('Time $currentTime: ${processList[processIndex].id} added to Q0');
        processIndex++;
      }

      Process? selectedProcess;
      int selectedQueue = -1;

      // Find the highest priority non-empty queue
      for (int i = 0; i < queues.length; i++) {
        if (queues[i].isNotEmpty) {
          selectedProcess = queues[i].removeAt(0);
          selectedQueue = i;
          break;
        }
      }

      if (selectedProcess == null) {
        currentTime++;
        continue;
      }

      final startTime = currentTime;
      int executionTime;

      if (!selectedProcess.hasStarted) {
        selectedProcess.hasStarted = true;
        selectedProcess.responseTime = startTime - selectedProcess.arrivalTime;
      }

      // Determine execution time based on queue
      if (quantums[selectedQueue] == 0) {
        // FCFS in lowest queue
        executionTime = selectedProcess.remainingTime;
      } else {
        // Round Robin in higher queues
        executionTime = min(quantums[selectedQueue], selectedProcess.remainingTime);
      }

      selectedProcess.remainingTime -= executionTime;
      currentTime += executionTime;

      ganttChart.add(
        GanttSegment(
          processId: selectedProcess.id,
          startTime: startTime,
          endTime: currentTime,
          isPreempted: selectedProcess.remainingTime > 0 && quantums[selectedQueue] != 0,
        ),
      );

      steps.add(
        'Time $startTime-$currentTime: ${selectedProcess.id} executed from Q$selectedQueue (Remaining=${selectedProcess.remainingTime})',
      );

      if (selectedProcess.remainingTime > 0) {
        // Move to next lower priority queue (aging mechanism)
        int nextQueue = min(selectedQueue + 1, queues.length - 1);
        queues[nextQueue].add(selectedProcess);
        steps.add('Time $currentTime: ${selectedProcess.id} aged down to Q$nextQueue');
      } else {
        selectedProcess.completionTime = currentTime;
        selectedProcess.turnaroundTime =
            selectedProcess.completionTime! - selectedProcess.arrivalTime;
        selectedProcess.waitingTime =
            selectedProcess.turnaroundTime! - selectedProcess.burstTime;
        completed.add(selectedProcess);
      }
    }

    return _calculateMetrics(processList, ganttChart, steps);
  }

  static ScheduleResult _calculateMetrics(
    List<Process> processes,
    List<GanttSegment> ganttChart,
    List<String> steps,
  ) {
    final totalTurnaroundTime = processes.fold<num>(
      0,
      (sum, p) => sum + (p.turnaroundTime ?? 0),
    );
    final totalWaitingTime = processes.fold<num>(
      0,
      (sum, p) => sum + (p.waitingTime ?? 0),
    );
    final totalResponseTime = processes.fold<num>(
      0,
      (sum, p) => sum + (p.responseTime ?? 0),
    );
    final totalBurstTime = processes.fold<num>(
      0,
      (sum, p) => sum + p.burstTime,
    );
    final totalTime = ganttChart.isEmpty ? 0 : ganttChart.last.endTime;

    final averageTurnaroundTime = processes.isEmpty
        ? 0.0
        : totalTurnaroundTime / processes.length;
    final averageWaitingTime = processes.isEmpty
        ? 0.0
        : totalWaitingTime / processes.length;
    final averageResponseTime = processes.isEmpty
        ? 0.0
        : totalResponseTime / processes.length;

    final cpuUtilization = totalTime > 0
        ? (totalBurstTime / totalTime) * 100
        : 0.0;
    final throughput = totalTime > 0 ? processes.length / totalTime : 0.0;

    steps.addAll([
      '',
      'Results:',
      'Average Turnaround Time: ${averageTurnaroundTime.toStringAsFixed(2)}',
      'Average Waiting Time: ${averageWaitingTime.toStringAsFixed(2)}',
      'Average Response Time: ${averageResponseTime.toStringAsFixed(2)}',
      'CPU Utilization: ${cpuUtilization.toStringAsFixed(2)}%',
      'Throughput: ${throughput.toStringAsFixed(2)} processes/unit time',
    ]);

    return ScheduleResult(
      processes: processes,
      ganttChart: ganttChart,
      averageTurnaroundTime: averageTurnaroundTime,
      averageWaitingTime: averageWaitingTime,
      averageResponseTime: averageResponseTime,
      cpuUtilization: cpuUtilization,
      throughput: throughput,
      steps: steps,
    );
  }
}
