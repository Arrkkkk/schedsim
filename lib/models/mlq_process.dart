import 'process.dart';

class MLQProcess {
  final String id;
  final int arrivalTime;
  final int burstTime;
  final int priority;
  final int queue; // Queue assignment (1, 2, 3, etc.)
  int remainingTime;
  int completionTime;
  int turnaroundTime;
  int waitingTime;
  int responseTime;
  bool hasStarted;
  int firstResponseTime;

  MLQProcess({
    required this.id,
    required this.arrivalTime,
    required this.burstTime,
    this.priority = 0,
    required this.queue,
    this.completionTime = 0,
    this.turnaroundTime = 0,
    this.waitingTime = 0,
    this.responseTime = 0,
    this.hasStarted = false,
    this.firstResponseTime = -1,
  }) : remainingTime = burstTime;

  MLQProcess copy() {
    return MLQProcess(
      id: id,
      arrivalTime: arrivalTime,
      burstTime: burstTime,
      priority: priority,
      queue: queue,
      completionTime: completionTime,
      turnaroundTime: turnaroundTime,
      waitingTime: waitingTime,
      responseTime: responseTime,
      hasStarted: hasStarted,
      firstResponseTime: firstResponseTime,
    )..remainingTime = remainingTime;
  }

  // Convert from regular Process to MLQProcess
  factory MLQProcess.fromProcess(Process process, int queue) {
    return MLQProcess(
      id: process.id,
      arrivalTime: process.arrivalTime,
      burstTime: process.burstTime,
      priority: process.priority,
      queue: queue,
    );
  }

  // Convert to regular Process for compatibility
  Process toProcess() {
    return Process(
      id: id,
      arrivalTime: arrivalTime,
      burstTime: burstTime,
      priority: priority,
      completionTime: completionTime,
      turnaroundTime: turnaroundTime,
      waitingTime: waitingTime,
      responseTime: responseTime,
      hasStarted: hasStarted,
      firstResponseTime: firstResponseTime,
    )..remainingTime = remainingTime;
  }
}
