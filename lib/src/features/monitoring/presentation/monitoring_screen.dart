import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'monitoring_controller.dart';
import 'monitoring_state.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../../generated/l10n/app_localizations.dart';

class MonitoringScreen extends ConsumerStatefulWidget {
  final int? patientId;

  const MonitoringScreen({super.key, this.patientId});

  @override
  ConsumerState<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends ConsumerState<MonitoringScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _shouldAutoScroll = true;

  @override
  void initState() {
    super.initState();
    // Detect user scrolling to disable auto-scroll
    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      // If user scrolls away from right edge (more than 50px), stop auto-scrolling
      if (maxScroll - currentScroll > 50) {
        _shouldAutoScroll = false;
      } else {
        _shouldAutoScroll = true;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(monitoringControllerProvider(widget.patientId));
    final controller = ref.read(
      monitoringControllerProvider(widget.patientId).notifier,
    );

    // Smart Auto-Scroll Trigger
    ref.listen(monitoringControllerProvider(widget.patientId), (prev, next) {
      if (next.bpmData.length > (prev?.bpmData.length ?? 0)) {
        if (_shouldAutoScroll) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Fetal Monitoring')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Connection Status (Top Bar) - Only show if granted
            if (state.permissionStatus == PermissionStatus.granted &&
                state.status == MonitoringStatus.idle) ...[
              // Connection Status Card with new UX
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ConnectionIndicator(
                        isConnected:
                            state.connectionStatus ==
                            DeviceConnectionStatus.connected,
                        isConnecting:
                            state.connectionStatus ==
                            DeviceConnectionStatus.scanning,
                        deviceName: state.isSimulation
                            ? l10n.simulationMode
                            : l10n.dopplerMonitor,
                        size: ConnectionIndicatorSize.large,
                      ),
                      const Spacer(),
                      if (state.connectionStatus ==
                          DeviceConnectionStatus.disconnected)
                        FilledButton.tonal(
                          onPressed: controller.connectToDevice,
                          child: Text(l10n.connect),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Status Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.statusLabel(state.status.name.toUpperCase()),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(l10n.durationSeconds(state.durationSeconds)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        PulseAnimation(
                          bpm: state.currentBpm,
                          isAnimating: (state.currentBpm ?? 0) > 0,
                          child: Text(
                            '${state.currentBpm ?? '--'}',
                            style: AppTypography.bpmDisplay,
                          ),
                        ),
                        Text(l10n.bpmLabel, style: AppTypography.bpmUnit),
                        if (state.currentBpm != null)
                          BpmStatusIndicator(
                            bpm: state.currentBpm,
                            size: BpmIndicatorSize.small,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Medical Disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.medicalDisclaimerContent,
                      style: const TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Error Message with Soft Error Widget
            if (state.errorMessage != null)
              SoftErrorWidget(message: state.errorMessage!, isInline: true),

            // Chart
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final chartAreaWidth = constraints.maxWidth;
                    const pointsOnScreen = 60;
                    final pixelsPerPoint = chartAreaWidth / pointsOnScreen;

                    final dataLength = state.bpmData.length;
                    final contentWidth = max(
                      chartAreaWidth,
                      dataLength * pixelsPerPoint,
                    );

                    return SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      // Prevent bouncing physics if content fits
                      physics: contentWidth > chartAreaWidth
                          ? const BouncingScrollPhysics()
                          : const ClampingScrollPhysics(),
                      child: SizedBox(
                        width: contentWidth,
                        child: LineChart(
                          LineChartData(
                            clipData: const FlClipData.all(),
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(color: Colors.black12),
                            ),
                            minX: 0,
                            // Ensure maxX matches width scaling
                            maxX: max(60, dataLength.toDouble()),
                            minY: 50,
                            maxY: 200,
                            lineBarsData: [
                              LineChartBarData(
                                spots: state.bpmData
                                    .asMap()
                                    .entries
                                    .where((e) => e.value > 30)
                                    .map((e) {
                                      return FlSpot(
                                        e.key.toDouble(),
                                        e.value.toDouble(),
                                      );
                                    })
                                    .toList(),
                                isCurved: true,
                                color: const Color(0xFFE91E63),
                                barWidth: 3,
                                dotData: const FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Controls Logic based on Permission
            if (state.status == MonitoringStatus.idle ||
                state.status == MonitoringStatus.completed)
              _buildIdleControls(context, controller, state),

            if (state.status == MonitoringStatus.monitoring)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: controller.stopMonitoring,
                  icon: const Icon(Icons.stop),
                  label: Text(l10n.stopRecording),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),

            if (state.status == MonitoringStatus.completed)
              _buildSaveButton(context, controller, state),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleControls(
    BuildContext context,
    MonitoringController controller,
    MonitoringState state,
  ) {
    final l10n = AppLocalizations.of(context)!;
    if (state.permissionStatus == PermissionStatus.granted) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () async {
            // Show medical disclaimer before first monitoring
            final accepted = await MedicalDisclaimerDialog.showIfNeeded(
              context,
            );
            if (accepted && context.mounted) {
              controller.startMonitoring();
            }
          },
          icon: const Icon(Icons.play_arrow),
          label: Text(l10n.startRecording),
          style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
        ),
      );
    } else if (state.permissionStatus == PermissionStatus.pending) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: Colors.orange.shade50,
        child: Column(
          children: [
            const Icon(Icons.hourglass_empty, color: Colors.orange, size: 48),
            const SizedBox(height: 12),
            Text(
              l10n.waitingForDoctorApproval,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              l10n.requestSentToDoctor,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    } else if (state.permissionStatus == PermissionStatus.none) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: controller.requestPermission,
          icon: const Icon(Icons.lock_open),
          label: Text(l10n.requestPermissionToMonitor),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.all(16),
            backgroundColor: Colors.orange,
          ),
        ),
      );
    } else {
      // Loading with Breathing Loader
      return Center(child: BreathingLoader(size: 60, message: l10n.loading));
    }
  }

  Widget _buildSaveButton(
    BuildContext context,
    MonitoringController controller,
    MonitoringState state,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () async {
            String? notes;

            // If Doctor Mode (patientId provided), ask for notes
            if (widget.patientId != null) {
              notes = await showDialog<String>(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  final notesController = TextEditingController();
                  return AlertDialog(
                    title: Text(l10n.doctorAnalysis),
                    content: TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Enter clinical notes...',
                        hintText: 'e.g., Normal FHR, localized movement',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.skip),
                      ),
                      FilledButton(
                        onPressed: () =>
                            Navigator.pop(context, notesController.text),
                        child: Text(l10n.saveRecord),
                      ),
                    ],
                  );
                },
              );
            }

            try {
              await controller.saveRecord(notes: notes);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.recordSavedSuccessfully)),
                );
                context.pop();
              }
            } catch (e) {
              if (context.mounted) {
                if (e.toString().contains(l10n.patientProfileNotFound)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.patientProfileNotFoundMessage)),
                  );
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            }
          },
          icon: const Icon(Icons.save),
          label: const Text('Save Record'),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
        ),
      ),
    );
  }
}
