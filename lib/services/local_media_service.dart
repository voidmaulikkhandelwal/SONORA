import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as p;

class LocalMediaService {
  static const _boxName = 'LOCAL_MEDIA';
  final Box _box = Hive.box(_boxName);

  List<Map<String, dynamic>> get tracks {
    final items = <Map<String, dynamic>>[];
    for (final value in _box.values) {
      if (value is Map) {
        items.add(Map<String, dynamic>.from(value));
      }
    }
    items.sort((a, b) => (a['title'] ?? '').toString().toLowerCase().compareTo(
          (b['title'] ?? '').toString().toLowerCase(),
        ));
    return items;
  }

  Future<int> importFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const [
        'mp3',
        'm4a',
        'wav',
        'flac',
        'aac',
        'ogg',
        'opus',
        'wma',
      ],
    );

    if (result == null) return 0;

    var added = 0;
    for (final picked in result.files) {
      final filePath = picked.path;
      if (filePath == null || filePath.isEmpty) continue;

      final file = File(filePath);
      if (!await file.exists()) continue;

      final title = picked.name.contains('.')
          ? p.basenameWithoutExtension(picked.name)
          : picked.name;
      final key = filePath.toLowerCase();

      await _box.put(key, {
        'videoId': key,
        'localPath': filePath,
        'title': title.trim().isEmpty ? 'Local track' : title.trim(),
        'artist': 'Local music',
        'subtitle': 'Local file',
        'duration': null,
        'thumbnails': <Map<String, String>>[],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      });
      added++;
    }
    return added;
  }

  Future<void> remove(String filePath) async {
    await _box.delete(filePath.toLowerCase());
  }

  Future<void> clearMissingFiles() async {
    final missing = <dynamic>[];
    for (final key in _box.keys) {
      final item = _box.get(key);
      final filePath = item is Map ? item['localPath']?.toString() : null;
      if (filePath == null || !await File(filePath).exists()) {
        missing.add(key);
      }
    }
    if (missing.isNotEmpty) await _box.deleteAll(missing);
  }
}
