class GanttSegment {
  final String processId;
  final int startTime;
  final int endTime;
  final bool isPreempted;

  GanttSegment({
    required this.processId,
    required this.startTime,
    required this.endTime,
    this.isPreempted = false,
  });

  int get duration => endTime - startTime;
}
