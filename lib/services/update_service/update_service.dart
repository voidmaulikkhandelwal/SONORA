import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:sonora/services/update_service/models/update_info.dart';
import 'package:sonora/services/update_service/widgets/update_checking.dart';
import 'package:sonora/services/update_service/widgets/update_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

class UpdateService {
  /// SONORA has no remote update feed yet, so no update is ever reported.
  /// To enable update checks later, point [feedUrl] at a JSON file that
  /// contains {"version": "x.y.z"} and uncomment the logic below.
  static const String feedUrl = '';

  static Future<UpdateInfo?> checkForUpdate() async {
    if (feedUrl.isEmpty) return null;
    try {
      final package = await PackageInfo.fromPlatform();
      final currentVersion = Version.parse(package.version);
      final response = await http.get(Uri.parse(feedUrl));
      if (response.statusCode != 200) return null;
      final Map<String, dynamic> data = jsonDecode(response.body);
      final remoteVersion =
          Version.parse(data['version']?.toString() ?? '0.0.0');
      if (remoteVersion > currentVersion) {
        return UpdateInfo(
          version: remoteVersion,
          name: 'New Update Available',
          body: 'A new version of SONORA is available.',
          publishedAt: '',
          downloadUrl: data['url']?.toString() ?? '',
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error checking for update: $e');
      return null;
    }
  }

  /* ─────────────────────────────────────────────
   * 2️⃣ AUTO CHECK (NO LOADER)
   * ───────────────────────────────────────────── */
  static Future<void> autoCheck(BuildContext context) async {
    final update = await checkForUpdate();
    if (update == null || !context.mounted) return;

    await showUpdateDialog(context, update);
  }

  /* ─────────────────────────────────────────────
   * 3️⃣ MANUAL CHECK (SHOW LOADER)
   * ───────────────────────────────────────────── */
  static Future<void> manualCheck(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: false,
      builder: (_) => const UpdateCheckingDialog(),
    );

    final update = await checkForUpdate();

    if (!context.mounted) return;
    Navigator.pop(context); // close loader

    if (update != null) {
      await showUpdateDialog(context, update);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You are already on the latest version')),
      );
    }
  }

  /* ─────────────────────────────────────────────
   * 4️⃣ DIALOG
   * ───────────────────────────────────────────── */
  static Future<void> showUpdateDialog(
    BuildContext context,
    UpdateInfo info,
  ) {
    return showDialog(
      context: context,
      useRootNavigator: false,
      builder: (_) => UpdateDialog(info),
    );
  }
}
