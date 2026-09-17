import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:schedsim/main.dart';

void main() {
  testWidgets('CPU Scheduler app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: CPUSchedulerApp()));

    // Verify that the app title is displayed.
    expect(find.text('CPU Scheduling Simulator'), findsOneWidget);
    expect(find.text('Select a Scheduling Algorithm'), findsOneWidget);
  });
}
