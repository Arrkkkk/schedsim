class Process {
  final String id;
  final int arrivalTime;
  final int burstTime;
  final int priority;
  int remainingTime;
  int completionTime;
  int turnaroundTime;
  int waitingTime;
  int responseTime;
  bool hasStarted;
  int firstResponseTime;

  Process({
    required this.id,
    required this.arrivalTime,
    required this.burstTime,
    this.priority = 0,
    this.completionTime = 0,
    this.turnaroundTime = 0,
    this.waitingTime = 0,
    this.responseTime = 0,
    this.hasStarted = false,
    this.firstResponseTime = -1,
  }) : remainingTime = burstTime;

  Process copy() {
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
