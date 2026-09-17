import 'gantt_segment.dart';
import 'process.dart';

class ScheduleResult {
  final List<Process> processes;
  final List<GanttSegment> ganttChart;
  final double averageTurnaroundTime;
  final double averageWaitingTime;
  final double averageResponseTime;
  final double cpuUtilization;
  final double throughput;
  final List<String> steps;

  ScheduleResult({
    required this.processes,
    required this.ganttChart,
    required this.averageTurnaroundTime,
    required this.averageWaitingTime,
    required this.averageResponseTime,
    required this.cpuUtilization,
    required this.throughput,
    required this.steps,
  });
}
