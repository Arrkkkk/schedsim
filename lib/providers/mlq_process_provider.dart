import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mlq_process.dart';

final mlqProcessListProvider = StateNotifierProvider<MLQProcessListNotifier, List<MLQProcess>>((ref) {
  return MLQProcessListNotifier();
});

class MLQProcessListNotifier extends StateNotifier<List<MLQProcess>> {
  MLQProcessListNotifier() : super([]);

  void addProcess(MLQProcess process) {
    state = [...state, process];
  }

  void removeProcess(int index) {
    final newList = [...state];
    newList.removeAt(index);
    state = newList;
  }

  void updateProcess(int index, MLQProcess process) {
    final newList = [...state];
    newList[index] = process;
    state = newList;
  }

  void clearProcesses() {
    state = [];
  }

  void generateRandomProcesses(int count) {
    final random = Random();
    final processes = <MLQProcess>[];
    
    for (int i = 0; i < count; i++) {
      processes.add(MLQProcess(
        id: 'P${i + 1}',
        arrivalTime: random.nextInt(10),
        burstTime: random.nextInt(15) + 1,
        priority: random.nextInt(10) + 1,
        queue: random.nextInt(3) + 1, // Random queue 1, 2, or 3
      ));
    }
    
    state = processes;
  }

  void loadExampleProcesses() {
    state = [
      MLQProcess(id: 'P1', arrivalTime: 0, burstTime: 5, priority: 1, queue: 1),
      MLQProcess(id: 'P2', arrivalTime: 1, burstTime: 3, priority: 2, queue: 2),
      MLQProcess(id: 'P3', arrivalTime: 2, burstTime: 8, priority: 3, queue: 3),
      MLQProcess(id: 'P4', arrivalTime: 3, burstTime: 6, priority: 1, queue: 1),
    ];
  }
}
