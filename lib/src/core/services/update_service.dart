import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

// CONFIG: Change these to your repository details
const _githubOwner = 'freeluncher'; // TODO: Change this
const _githubRepo = 'dopply-v2'; // TODO: Change this
// If private repo, add header: 'Authorization': 'token YOUR_TOKEN'

class ReleaseInfo {
  final String version;
  final String tagName;
  final String body; // Release notes
  final String downloadUrl;

  ReleaseInfo({
    required this.version,
    required this.tagName,
    required this.body,
    required this.downloadUrl,
  });
}

class UpdateService {
  Future<ReleaseInfo?> checkForUpdate() async {
    // 1. Platform Check
    if (!Platform.isAndroid) return null;

    try {
      // 2. Fetch Current Version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = Version.parse(packageInfo.version);

      // 3. Fetch Latest Release from GitHub
      final url = Uri.parse(
        'https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) {
        debugPrint(
          'UpdateService: Failed to fetch releases. Status ${response.statusCode}',
        );
        return null;
      }

      final json = jsonDecode(response.body);
      final String tagName = json['tag_name'] ?? '';

      // Handle 'v' prefix (v1.0.0 -> 1.0.0)
      final cleanTag = tagName.startsWith('v') ? tagName.substring(1) : tagName;

      // Parse remote version
      Version remoteVersion;
      try {
        remoteVersion = Version.parse(cleanTag);
      } catch (e) {
        debugPrint('UpdateService: Failed to parse remote version: $cleanTag');
        return null; // Invalid tag format
      }

      // 4. Compare Versions
      if (remoteVersion > currentVersion) {
        // Update available!
        // Find APK asset
        final List assets = json['assets'] ?? [];
        final apkAsset = assets.firstWhere(
          (asset) => (asset['name'] as String).endsWith('.apk'),
          orElse: () => null,
        );

        if (apkAsset == null) {
          debugPrint('UpdateService: No APK found in release assets.');
          return null;
        }

        return ReleaseInfo(
          version: cleanTag,
          tagName: tagName,
          body: json['body'] ?? 'No release notes.',
          downloadUrl: apkAsset['browser_download_url'],
        );
      }
    } catch (e) {
      debugPrint('UpdateService Error: $e');
    }

    return null;
  }

  Stream<OtaEvent> runUpdate(String downloadUrl) {
    // 5. Trigger OTA Update
    // destinationFilename is optional, usually handled by OS or package.
    // 'dopply_update.apk'
    try {
      return OtaUpdate().execute(
        downloadUrl,
        destinationFilename: 'dopply_update.apk',
      );
    } catch (e) {
      debugPrint('UpdateService: OTA Error: $e');
      rethrow;
    }
  }
}
