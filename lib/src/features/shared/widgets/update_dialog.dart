import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import '../../../core/services/update_service.dart';

/// Dialog for displaying update information and initiating the update process.
///
/// This dialog shows the available update version, release notes, and provides options to update now or later.
/// It uses the [UpdateService] to download and install the update.
///
/// Usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => UpdateDialog(releaseInfo: releaseInfo),
/// );
/// ```

class UpdateDialog extends StatefulWidget {
  final ReleaseInfo releaseInfo;

  const UpdateDialog({super.key, required this.releaseInfo});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  final UpdateService _updateService = UpdateService();
  bool _isDownloading = false;
  String? _progress;
  OtaStatus? _status;

  void _startUpdate() {
    setState(() {
      _isDownloading = true;
      _progress = "0";
    });

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    _updateService
        .runUpdate(widget.releaseInfo.downloadUrl)
        .listen(
          (OtaEvent event) {
            setState(() {
              _status = event.status;
              _progress = event.value;
            });

            if (_status == OtaStatus.PERMISSION_NOT_GRANTED_ERROR) {
              _resetState();
              scaffoldMessenger.showSnackBar(
                const SnackBar(
                  content: Text('Permission not granted to install apk.'),
                ),
              );
            }
          },
          onError: (e) {
            _resetState();
            debugPrint("Download Error: $e");
          },
        );
  }

  void _resetState() {
    if (mounted) {
      setState(() {
        _isDownloading = false;
        _progress = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update Available ${widget.releaseInfo.version}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isDownloading) ...[
            const Text('A new version of Dopply is available.'),
            const SizedBox(height: 8),
            const Text(
              'Release Notes:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              width: double.maxFinite,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SingleChildScrollView(
                child: Text(widget.releaseInfo.body),
              ),
            ),
          ] else ...[
            const Text('Downloading Update...'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _progress != null
                  ? (double.tryParse(_progress!) ?? 0) / 100
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              '$_progress%',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: _isDownloading
          ? [] // Hide buttons while downloading
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Later'),
              ),
              FilledButton(
                onPressed: _startUpdate,
                child: const Text('Update Now'),
              ),
            ],
    );
  }
}
