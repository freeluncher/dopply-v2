import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import '../../../core/services/update_service.dart';

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

    _updateService
        .runUpdate(widget.releaseInfo.downloadUrl)
        .listen(
          (OtaEvent event) {
            setState(() {
              _status = event.status;
              _progress = event.value;
            });

            // Handle specific statuses if needed
            if (_status == OtaStatus.PERMISSION_NOT_GRANTED_ERROR) {
              _resetState();
              ScaffoldMessenger.of(context).showSnackBar(
                // Context might be unstable if dialog, use key/global if needed
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
