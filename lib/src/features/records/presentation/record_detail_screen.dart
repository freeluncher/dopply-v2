import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../application/pdf_service.dart';

final recordDetailProvider = FutureProvider.family
    .autoDispose<Map<String, dynamic>, int>((ref, recordId) async {
      final data = await Supabase.instance.client
          .from('records')
          .select('*, patients(name)')
          .eq('id', recordId)
          .single();
      return data;
    });

class RecordDetailScreen extends ConsumerWidget {
  final int recordId;

  const RecordDetailScreen({super.key, required this.recordId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordAsync = ref.watch(recordDetailProvider(recordId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Details'),
        actions: [
          recordAsync.when(
            data: (record) => IconButton(
              icon: const Icon(Icons.print),
              onPressed: () async {
                // PDF GENERATION LOGIC
                // We need more patient data than just name
                try {
                  final patientId = record['patient_id'];
                  final patientProfile = await Supabase.instance.client
                      .from('patients')
                      .select('*, profiles(full_name)')
                      .eq('id', patientId)
                      .single();

                  // Flatten profile data
                  final fullProfile = Map<String, dynamic>.from(patientProfile);
                  if (patientProfile['profiles'] != null) {
                    fullProfile['full_name'] =
                        patientProfile['profiles']['full_name'];
                  }
                  fullProfile['patient_data'] =
                      patientProfile; // Pass recursive for simple access in PDF service

                  // Doctor Name?
                  String? doctorName;
                  try {
                    final doctorData = await Supabase.instance.client
                        .from('doctor_patient')
                        .select('profiles:doctor_id(full_name)')
                        .eq('patient_id', patientId)
                        .maybeSingle();
                    if (doctorData != null && doctorData['profiles'] != null) {
                      doctorName = doctorData['profiles']['full_name'];
                    }
                  } catch (_) {}

                  await PdfService().generateAndPrint(
                    record,
                    fullProfile,
                    doctorName: doctorName,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to generate PDF: $e')),
                  );
                }
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: recordAsync.when(
        data: (record) {
          final bpmData = List<int>.from(record['bpm_data'] ?? []);
          final date = DateTime.parse(record['start_time']);
          final duration = record['duration_minutes'] ?? 0.0;
          final classification = record['classification'] ?? 'Unknown';
          final notes = record['notes'];
          final patientName = record['patients']?['name'] ?? 'Unknown Patient';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Stats
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Patient',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  patientName,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Date',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  DateFormat('dd MMM yyyy').format(date),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              label: 'Avg BPM',
                              value: (record['average_bpm'] as num)
                                  .toStringAsFixed(1),
                              highlight: true,
                            ),
                            _StatItem(
                              label: 'Duration',
                              value: '${(duration as num).toStringAsFixed(1)}m',
                            ),
                            _StatItem(
                              label: 'Result',
                              value: classification,
                              color: _getColorForClassification(classification),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  'BPM History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                // CHART
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                  ),
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(
                        show: true,
                        drawVerticalLine: false,
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 10,
                            reservedSize:
                                30, // Increased space for bottom labels
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 20,
                            reservedSize: 40, // Increased space for left labels
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.right,
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.black12),
                      ),
                      minY: 60,
                      maxY: 200,
                      lineBarsData: [
                        LineChartBarData(
                          spots: bpmData.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value.toDouble());
                          }).toList(),
                          isCurved: true,
                          color: const Color(0xFFE91E63),
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),

                if (notes != null && notes.toString().isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Notes', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.yellow.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        notes,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                ],

                if (record['doctor_notes'] != null &&
                    record['doctor_notes'].toString().isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(
                        Icons.medical_services,
                        color: Color(0xFFE91E63),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Doctor\'s Analysis',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record['doctor_notes'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          Text(
                            "Verified by Doctor",
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        error: (err, stack) => Center(child: Text('Error: $err')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Color _getColorForClassification(String? classification) {
    if (classification == null) return Colors.grey;
    final lower = classification.toLowerCase();
    if (lower.contains('bradycardia')) return Colors.orange;
    if (lower.contains('tachycardia')) return Colors.red;
    if (lower.contains('normal')) return Colors.green;
    return Colors.grey;
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final Color? color;

  const _StatItem({
    required this.label,
    required this.value,
    this.highlight = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color:
                color ?? (highlight ? const Color(0xFFE91E63) : Colors.black87),
          ),
        ),
      ],
    );
  }
}
