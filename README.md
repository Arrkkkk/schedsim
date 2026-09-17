# SchedSim

Interactive **CPU scheduling simulator** built with Flutter. Add processes, run classic OS scheduling algorithms, and inspect Gantt charts, step-by-step traces, and performance metrics — then compare algorithms side by side.

Developed by [Rajit Agrawal](https://github.com/Arrkkkk).

## Algorithms

| Algorithm | Notes |
| --- | --- |
| **FCFS** | First Come First Serve |
| **SJF** | Shortest Job First (non-preemptive) |
| **SRTF** | Shortest Remaining Time First (preemptive SJF) |
| **Round Robin** | Configurable time quantum |
| **Priority** | Preemptive and non-preemptive (lower number = higher priority) |
| **MLQ** | Multilevel Queue with configurable per-queue algorithms |
| **MLFQ** | Multilevel Feedback Queue |
| **Compare All** | Same process set across algorithms |

## Features

- Process editor with validation, unique IDs, and random / pattern generation
- Interactive Gantt chart of CPU allocation over time
- Per-process waiting, turnaround, response, and completion times
- Average metrics for the full schedule
- Step-by-step explanation of scheduler decisions
- Side-by-side algorithm comparison
- Export results to PDF or CSV
- Light and dark themes

## Screenshots

Run the app and try **FCFS** or **Compare All** first — those flows show the Gantt chart, results table, and comparison view.

## Getting started

**Requirements:** [Flutter](https://docs.flutter.dev/get-started/install) 3.x with Dart SDK `^3.9.2`.

```bash
git clone https://github.com/Arrkkkk/schedsim.git
cd schedsim
flutter pub get
flutter run
```

Target a specific device if you have more than one attached:

```bash
flutter devices
flutter run -d chrome          # web
flutter run -d macos           # desktop
flutter run -d <device-id>     # mobile
```

## How to use

1. Open **CPU Scheduling Simulator** and pick an algorithm (or **Compare All**).
2. Add processes: arrival time, burst time, and priority when required. Round Robin uses a time quantum; Priority can be preemptive or not.
3. Run the simulation.
4. Switch among **Gantt**, **Results**, **Steps**, and comparison tabs.
5. Optionally export PDF/CSV or generate a random process set from the menu.

**MLQ** has its own screen: assign processes to queues and choose each queue’s policy (FCFS, SJF, SRTF, Round Robin, or Priority).

## Project layout

```
lib/
  main.dart                 App entry and theme
  models/                   Process, Gantt segment, schedule result
  providers/                Riverpod process, MLQ, and theme state
  screens/                  Home, algorithm, and MLQ screens
  services/                 Scheduling engines and PDF/CSV export
  widgets/                  Forms, charts, tables, comparison, about
test/                       Algorithm and Gantt tests
```

## Tests

```bash
flutter test
```

## Tech stack

Flutter, Dart, Riverpod, fl_chart, Material Design.
