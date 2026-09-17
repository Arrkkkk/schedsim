import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import '../models/schedule_result.dart';
import '../models/gantt_segment.dart';

class ExportService {
  static Future<String> exportToPDF(
    ScheduleResult result,
    String algorithmName,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 20),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(width: 2, color: PdfColors.blue),
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'CPU Scheduling Algorithm Results',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Algorithm: $algorithmName',
                  style: pw.TextStyle(fontSize: 18, color: PdfColors.blue700),
                ),
                pw.Text(
                  'Generated: ${DateTime.now().toString().split('.')[0]}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 30),

          // Process Details Table
          pw.Text(
            'Process Details',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 15),

          pw.TableHelper.fromTextArray(
            context: context,
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
            cellStyle: const pw.TextStyle(fontSize: 10),
            cellAlignment: pw.Alignment.center,
            columnWidths: {
              0: const pw.FlexColumnWidth(1.5),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(1),
              5: const pw.FlexColumnWidth(1),
              6: const pw.FlexColumnWidth(1),
            },
            headers: ['Process', 'AT', 'BT', 'CT', 'TAT', 'WT', 'RT'],
            data: result.processes
                .map(
                  (process) => [
                    process.id,
                    process.arrivalTime.toString(),
                    process.burstTime.toString(),
                    process.completionTime.toString(),
                    process.turnaroundTime.toString(),
                    process.waitingTime.toString(),
                    process.responseTime.toString(),
                  ],
                )
                .toList(),
          ),

          pw.SizedBox(height: 10),

          // Table Legend
          pw.Container(
            padding: const pw.EdgeInsets.all(8),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Wrap(
              spacing: 15,
              runSpacing: 5,
              children: [
                pw.Text(
                  'AT: Arrival Time',
                  style: const pw.TextStyle(fontSize: 8),
                ),
                pw.Text(
                  'BT: Burst Time',
                  style: const pw.TextStyle(fontSize: 8),
                ),
                pw.Text(
                  'CT: Completion Time',
                  style: const pw.TextStyle(fontSize: 8),
                ),
                pw.Text(
                  'TAT: Turnaround Time',
                  style: const pw.TextStyle(fontSize: 8),
                ),
                pw.Text(
                  'WT: Waiting Time',
                  style: const pw.TextStyle(fontSize: 8),
                ),
                pw.Text(
                  'RT: Response Time',
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 30),

          // Gantt Chart
          pw.Text(
            'Gantt Chart',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 15),

          _buildGanttChart(result.ganttChart),

          pw.SizedBox(height: 30),

          // Performance Metrics
          pw.Text(
            'Performance Metrics',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 15),

          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue50,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.blue200),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildMetricRow(
                  'Average Turnaround Time:',
                  '${result.averageTurnaroundTime.toStringAsFixed(2)} units',
                ),
                _buildMetricRow(
                  'Average Waiting Time:',
                  '${result.averageWaitingTime.toStringAsFixed(2)} units',
                ),
                _buildMetricRow(
                  'Average Response Time:',
                  '${result.averageResponseTime.toStringAsFixed(2)} units',
                ),
                _buildMetricRow(
                  'CPU Utilization:',
                  '${result.cpuUtilization.toStringAsFixed(2)}%',
                ),
                _buildMetricRow(
                  'Throughput:',
                  '${result.throughput.toStringAsFixed(2)} processes/time unit',
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 30),

          // Step-by-Step Solution
          if (result.steps.isNotEmpty) ...[
            pw.Text(
              'Step-by-Step Solution',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 15),

            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey50,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: result.steps.take(15).map((step) {
                  final isHeader =
                      step.contains('Algorithm') || step.contains('Results:');
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(
                      step,
                      style: pw.TextStyle(
                        fontSize: isHeader ? 12 : 10,
                        fontWeight: isHeader
                            ? pw.FontWeight.bold
                            : pw.FontWeight.normal,
                        color: isHeader ? PdfColors.blue700 : PdfColors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          pw.SizedBox(height: 20),

          // Footer
          pw.Divider(),
          pw.Container(
            alignment: pw.Alignment.center,
            child: pw.Text(
              'Generated by CPU Scheduling Simulator App',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'CPU_Scheduling_${algorithmName}_$timestamp.pdf';
      final file = File('${directory.path}/$fileName');

      final pdfBytes = await pdf.save();
      await file.writeAsBytes(pdfBytes);

      return file.path;
    } catch (e) {
      throw Exception('Failed to save PDF: $e');
    }
  }

  static pw.Widget _buildGanttChart(List<GanttSegment> ganttChart) {
    if (ganttChart.isEmpty) {
      return pw.Text('No Gantt chart data available');
    }

    final totalTime = ganttChart.last.endTime;
    final colors = [
      PdfColors.blue300,
      PdfColors.green300,
      PdfColors.orange300,
      PdfColors.purple300,
      PdfColors.red300,
      PdfColors.teal300,
      PdfColors.indigo300,
      PdfColors.pink300,
    ];

    // Map process IDs to colors
    final processColors = <String, PdfColor>{};
    final uniqueProcesses = ganttChart.map((s) => s.processId).toSet().toList();
    for (int i = 0; i < uniqueProcesses.length; i++) {
      processColors[uniqueProcesses[i]] = colors[i % colors.length];
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Gantt chart bars
        pw.Container(
          height: 60,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Row(
            children: ganttChart.map((segment) {
              final flex = segment.duration;
              final color = processColors[segment.processId] ?? PdfColors.grey;

              return pw.Expanded(
                flex: flex,
                child: pw.Container(
                  height: 60,
                  decoration: pw.BoxDecoration(
                    color: color,
                    border: pw.Border.all(color: PdfColors.white, width: 1),
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      segment.processId,
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        pw.SizedBox(height: 5),

        // Time labels
        pw.Container(
          height: 20,
          child: pw.Row(
            children: [
              for (int i = 0; i <= totalTime; i++)
                if (i == 0 ||
                    i == totalTime ||
                    i % (totalTime > 20 ? 5 : 2) == 0)
                  pw.Positioned(
                    left: (i / totalTime) * 400, // Approximate positioning
                    child: pw.Text(
                      i.toString(),
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ),
            ],
          ),
        ),

        pw.SizedBox(height: 15),

        // Legend
        pw.Wrap(
          spacing: 15,
          runSpacing: 8,
          children: processColors.entries.map((entry) {
            return pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Container(
                  width: 12,
                  height: 12,
                  decoration: pw.BoxDecoration(
                    color: entry.value,
                    borderRadius: pw.BorderRadius.circular(2),
                  ),
                ),
                pw.SizedBox(width: 4),
                pw.Text(entry.key, style: const pw.TextStyle(fontSize: 10)),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  static pw.Widget _buildMetricRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(value, style: const pw.TextStyle(color: PdfColors.blue700)),
        ],
      ),
    );
  }

  static Future<String> exportToCSV(
    ScheduleResult result,
    String algorithmName,
  ) async {
    final List<List<dynamic>> rows = [];

    // Header
    rows.add([
      'Process',
      'Arrival Time',
      'Burst Time',
      'Completion Time',
      'Turnaround Time',
      'Waiting Time',
      'Response Time',
    ]);

    // Process data
    for (final process in result.processes) {
      rows.add([
        process.id,
        process.arrivalTime,
        process.burstTime,
        process.completionTime,
        process.turnaroundTime,
        process.waitingTime,
        process.responseTime,
      ]);
    }

    // Summary
    rows.add([]);
    rows.add(['Performance Metrics']);
    rows.add([
      'Average Turnaround Time',
      result.averageTurnaroundTime.toStringAsFixed(2),
    ]);
    rows.add([
      'Average Waiting Time',
      result.averageWaitingTime.toStringAsFixed(2),
    ]);
    rows.add([
      'Average Response Time',
      result.averageResponseTime.toStringAsFixed(2),
    ]);
    rows.add(['CPU Utilization (%)', result.cpuUtilization.toStringAsFixed(2)]);
    rows.add(['Throughput', result.throughput.toStringAsFixed(2)]);

    // Gantt Chart
    rows.add([]);
    rows.add(['Gantt Chart']);
    rows.add(['Process', 'Start Time', 'End Time', 'Duration']);
    for (final segment in result.ganttChart) {
      rows.add([
        segment.processId,
        segment.startTime,
        segment.endTime,
        segment.duration,
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'CPU_Scheduling_${algorithmName}_$timestamp.csv';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(csv);
      return file.path;
    } catch (e) {
      throw Exception('Failed to save CSV: $e');
    }
  }
}
