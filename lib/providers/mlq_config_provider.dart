import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mlq_queue_config.dart';

final mlqConfigProvider = StateNotifierProvider<MLQConfigNotifier, List<MLQQueueConfig>>((ref) {
  return MLQConfigNotifier();
});

class MLQConfigNotifier extends StateNotifier<List<MLQQueueConfig>> {
  MLQConfigNotifier() : super(_getDefaultConfigs());

  static List<MLQQueueConfig> _getDefaultConfigs() {
    return [
      MLQQueueConfig(
        queueNumber: 1,
        name: 'Interactive',
        algorithm: 'Round Robin',
        timeQuantum: 4,
        priority: 1,
      ),
      MLQQueueConfig(
        queueNumber: 2,
        name: 'Batch',
        algorithm: 'FCFS',
        timeQuantum: null,
        priority: 2,
      ),
      MLQQueueConfig(
        queueNumber: 3,
        name: 'Background',
        algorithm: 'FCFS',
        timeQuantum: null,
        priority: 3,
      ),
    ];
  }

  void addQueue() {
    final newQueueNumber = state.length + 1;
    state = [
      ...state,
      MLQQueueConfig(
        queueNumber: newQueueNumber,
        name: 'Queue $newQueueNumber',
        algorithm: 'FCFS',
        timeQuantum: null,
        priority: newQueueNumber,
      ),
    ];
  }

  void removeQueue(int queueNumber) {
    if (state.length <= 1) return; // Keep at least one queue
    
    state = state.where((config) => config.queueNumber != queueNumber).toList();
    
    // Renumber remaining queues
    final updatedConfigs = <MLQQueueConfig>[];
    for (int i = 0; i < state.length; i++) {
      updatedConfigs.add(state[i].copyWith(
        queueNumber: i + 1,
        priority: i + 1,
      ));
    }
    state = updatedConfigs;
  }

  void updateQueue(int queueNumber, MLQQueueConfig updatedConfig) {
    state = state.map((config) {
      if (config.queueNumber == queueNumber) {
        return updatedConfig;
      }
      return config;
    }).toList();
  }

  void resetToDefault() {
    state = _getDefaultConfigs();
  }

  MLQQueueConfig? getQueueConfig(int queueNumber) {
    try {
      return state.firstWhere((config) => config.queueNumber == queueNumber);
    } catch (e) {
      return null;
    }
  }

  List<String> getAvailableAlgorithms() {
    return ['FCFS', 'SJF', 'SRTF', 'Round Robin', 'Priority'];
  }
}
