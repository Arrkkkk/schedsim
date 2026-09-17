class MLQQueueConfig {
  final int queueNumber;
  final String name;
  final String algorithm;
  final int? timeQuantum;
  final int priority; // Lower number = higher priority

  MLQQueueConfig({
    required this.queueNumber,
    required this.name,
    required this.algorithm,
    this.timeQuantum,
    required this.priority,
  });

  MLQQueueConfig copyWith({
    int? queueNumber,
    String? name,
    String? algorithm,
    int? timeQuantum,
    int? priority,
  }) {
    return MLQQueueConfig(
      queueNumber: queueNumber ?? this.queueNumber,
      name: name ?? this.name,
      algorithm: algorithm ?? this.algorithm,
      timeQuantum: timeQuantum ?? this.timeQuantum,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'queueNumber': queueNumber,
      'name': name,
      'algorithm': algorithm,
      'timeQuantum': timeQuantum,
      'priority': priority,
    };
  }

  factory MLQQueueConfig.fromJson(Map<String, dynamic> json) {
    return MLQQueueConfig(
      queueNumber: json['queueNumber'],
      name: json['name'],
      algorithm: json['algorithm'],
      timeQuantum: json['timeQuantum'],
      priority: json['priority'],
    );
  }

  @override
  String toString() {
    return 'Q$queueNumber ($name): $algorithm${timeQuantum != null ? ' (TQ=${timeQuantum}ms)' : ''}';
  }
}
