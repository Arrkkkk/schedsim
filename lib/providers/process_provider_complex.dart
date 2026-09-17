import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/process.dart';

final processListProvider =
    StateNotifierProvider<ProcessListNotifier, List<Process>>((ref) {
      return ProcessListNotifier();
    });

class ProcessListNotifier extends StateNotifier<List<Process>> {
  ProcessListNotifier() : super([]);

  /// Enhanced addProcess function with validation and duplicate prevention
  /// 
  /// Features:
  /// - Duplicate ID prevention with automatic ID generation
  /// - Input validation
  /// - Optional sorting by arrival time
  /// - Support for batch operations
  /// 
  /// Returns true if process was added successfully, false otherwise
  bool addProcess(Process process, {bool maintainSortedOrder = false}) {
    try {
      // Validate process parameters
      if (!_validateProcess(process)) {
        return false;
      }

      // Create a copy to avoid modifying the original
      Process processToAdd = process.copy();
      
      // Check for duplicate ID and generate unique one if needed
      processToAdd = _ensureUniqueId(processToAdd);
      
      // Add process to the list
      final newList = [...state, processToAdd];
      
      // Sort by arrival time if requested
      if (maintainSortedOrder) {
        newList.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
      }
      
      state = newList;
      return true;
    } catch (e) {
      // Handle any unexpected errors
      print('Error adding process: $e');
      return false;
    }
  }

  /// Add multiple processes at once
  /// 
  /// Returns the number of processes successfully added
  int addProcesses(List<Process> processes, {bool maintainSortedOrder = false}) {
    int addedCount = 0;
    
    for (final process in processes) {
      if (addProcess(process, maintainSortedOrder: maintainSortedOrder)) {
        addedCount++;
      }
    }
    
    return addedCount;
  }

  /// Add process with automatic ID generation
  /// 
  /// If id is empty or null, generates a unique ID automatically
  bool addProcessWithAutoId({
    String? id,
    required int arrivalTime,
    required int burstTime,
    int priority = 1,
    bool maintainSortedOrder = false,
  }) {
    // Generate ID if not provided
    final processId = id?.trim().isEmpty == true ? _generateUniqueId() : (id ?? _generateUniqueId());
    
    final process = Process(
      id: processId,
      arrivalTime: arrivalTime,
      burstTime: burstTime,
      priority: priority,
    );
    
    return addProcess(process, maintainSortedOrder: maintainSortedOrder);
  }

  /// Validate process parameters
  bool _validateProcess(Process process) {
    // Check if ID is not empty
    if (process.id.trim().isEmpty) {
      print('Error: Process ID cannot be empty');
      return false;
    }
    
    // Check if arrival time is non-negative
    if (process.arrivalTime < 0) {
      print('Error: Arrival time cannot be negative');
      return false;
    }
    
    // Check if burst time is positive
    if (process.burstTime <= 0) {
      print('Error: Burst time must be positive');
      return false;
    }
    
    // Check if priority is non-negative
    if (process.priority < 0) {
      print('Error: Priority cannot be negative');
      return false;
    }
    
    return true;
  }

  /// Ensure process has a unique ID
  Process _ensureUniqueId(Process process) {
    String originalId = process.id;
    String uniqueId = originalId;
    int counter = 1;
    
    // Check if ID already exists
    while (_idExists(uniqueId)) {
      uniqueId = '${originalId}_$counter';
      counter++;
    }
    
    // If ID was changed, create new process with unique ID
    if (uniqueId != originalId) {
      return Process(
        id: uniqueId,
        arrivalTime: process.arrivalTime,
        burstTime: process.burstTime,
        priority: process.priority,
        completionTime: process.completionTime,
        turnaroundTime: process.turnaroundTime,
        waitingTime: process.waitingTime,
        responseTime: process.responseTime,
        hasStarted: process.hasStarted,
        firstResponseTime: process.firstResponseTime,
      )..remainingTime = process.remainingTime;
    }
    
    return process;
  }

  /// Check if process ID already exists
  bool _idExists(String id) {
    return state.any((process) => process.id == id);
  }

  /// Generate a unique process ID
  String _generateUniqueId() {
    int counter = 1;
    String baseId = 'P';
    
    while (_idExists('$baseId$counter')) {
      counter++;
    }
    
    return '$baseId$counter';
  }

  /// Get the next available process ID
  String getNextAvailableId() {
    return _generateUniqueId();
  }

  /// Check if a process ID is available
  bool isIdAvailable(String id) {
    return !_idExists(id);
  }

  /// Remove process by ID instead of index
  bool removeProcessById(String id) {
    final index = state.indexWhere((process) => process.id == id);
    if (index != -1) {
      removeProcess(index);
      return true;
    }
    return false;
  }

  /// Update process by ID instead of index
  bool updateProcessById(String id, Process updatedProcess) {
    final index = state.indexWhere((process) => process.id == id);
    if (index != -1) {
      updateProcess(index, updatedProcess);
      return true;
    }
    return false;
  }

  /// Get process by ID
  Process? getProcessById(String id) {
    try {
      return state.firstWhere((process) => process.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get process index by ID
  int? getProcessIndexById(String id) {
    final index = state.indexWhere((process) => process.id == id);
    return index != -1 ? index : null;
  }

  /// Sort processes by arrival time
  void sortByArrivalTime() {
    final sortedList = [...state];
    sortedList.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));
    state = sortedList;
  }

  /// Sort processes by burst time
  void sortByBurstTime() {
    final sortedList = [...state];
    sortedList.sort((a, b) => a.burstTime.compareTo(b.burstTime));
    state = sortedList;
  }

  /// Sort processes by priority
  void sortByPriority() {
    final sortedList = [...state];
    sortedList.sort((a, b) => a.priority.compareTo(b.priority));
    state = sortedList;
  }

  /// Get processes that arrive at a specific time
  List<Process> getProcessesByArrivalTime(int arrivalTime) {
    return state.where((process) => process.arrivalTime == arrivalTime).toList();
  }

  /// Get processes with specific priority
  List<Process> getProcessesByPriority(int priority) {
    return state.where((process) => process.priority == priority).toList();
  }

  /// Get total burst time of all processes
  int getTotalBurstTime() {
    return state.fold(0, (sum, process) => sum + process.burstTime);
  }

  /// Get earliest arrival time
  int getEarliestArrivalTime() {
    if (state.isEmpty) return 0;
    return state.map((p) => p.arrivalTime).reduce((a, b) => a < b ? a : b);
  }

  /// Get latest arrival time
  int getLatestArrivalTime() {
    if (state.isEmpty) return 0;
    return state.map((p) => p.arrivalTime).reduce((a, b) => a > b ? a : b);
  }

  /// Get average burst time
  double getAverageBurstTime() {
    if (state.isEmpty) return 0.0;
    return getTotalBurstTime() / state.length;
  }

  /// Get average priority
  double getAveragePriority() {
    if (state.isEmpty) return 0.0;
    final totalPriority = state.fold(0, (sum, process) => sum + process.priority);
    return totalPriority / state.length;
  }

  /// Remove process by index (original method)
  void removeProcess(int index) {
    if (index >= 0 && index < state.length) {
      final newList = [...state];
      newList.removeAt(index);
      state = newList;
    }
  }

  /// Update process by index (original method)
  void updateProcess(int index, Process process) {
    if (index >= 0 && index < state.length) {
      final newList = [...state];
      newList[index] = process;
      state = newList;
    }
  }

  /// Clear all processes (original method)
  void clearProcesses() {
    state = [];
  }

  /// Generate random processes with enhanced features
  void generateRandomProcesses(int count, {
    int maxArrivalTime = 10,
    int maxBurstTime = 15,
    int maxPriority = 10,
    bool maintainSortedOrder = true,
  }) {
    final random = Random();
    final processes = <Process>[];

    for (int i = 0; i < count; i++) {
      processes.add(
        Process(
          id: _generateUniqueId(),
          arrivalTime: random.nextInt(maxArrivalTime),
          burstTime: random.nextInt(maxBurstTime) + 1,
          priority: random.nextInt(maxPriority) + 1,
        ),
      );
    }

    // Add all processes at once
    addProcesses(processes, maintainSortedOrder: maintainSortedOrder);
  }

  /// Generate processes with specific patterns
  void generatePatternProcesses({
    int count = 5,
    String pattern = 'mixed', // 'mixed', 'short_jobs', 'long_jobs', 'high_priority', 'low_priority'
    bool maintainSortedOrder = true,
  }) {
    final random = Random();
    final processes = <Process>[];

    for (int i = 0; i < count; i++) {
      int arrivalTime, burstTime, priority;

      switch (pattern) {
        case 'short_jobs':
          arrivalTime = random.nextInt(8);
          burstTime = random.nextInt(5) + 1; // 1-5
          priority = random.nextInt(5) + 1; // 1-5
          break;
        case 'long_jobs':
          arrivalTime = random.nextInt(5);
          burstTime = random.nextInt(10) + 10; // 10-19
          priority = random.nextInt(5) + 6; // 6-10
          break;
        case 'high_priority':
          arrivalTime = random.nextInt(10);
          burstTime = random.nextInt(15) + 1;
          priority = random.nextInt(3) + 1; // 1-3
          break;
        case 'low_priority':
          arrivalTime = random.nextInt(10);
          burstTime = random.nextInt(15) + 1;
          priority = random.nextInt(5) + 6; // 6-10
          break;
        default: // 'mixed'
          arrivalTime = random.nextInt(10);
          burstTime = random.nextInt(15) + 1;
          priority = random.nextInt(10) + 1;
          break;
      }

      processes.add(
        Process(
          id: _generateUniqueId(),
          arrivalTime: arrivalTime,
          burstTime: burstTime,
          priority: priority,
        ),
      );
    }

    addProcesses(processes, maintainSortedOrder: maintainSortedOrder);
  }
}
