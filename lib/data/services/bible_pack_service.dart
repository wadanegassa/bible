import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../local_db/database_helper.dart';
import '../models/bible_version_models.dart';

class BiblePackService {
  final DatabaseHelper _db = DatabaseHelper();

  Future<BibleCatalog> loadCatalog() async {
    final installed = await _db.getInstalledTranslationIds();
    final raw = await rootBundle.loadString('assets/bible/catalog.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return BibleCatalog.fromJson(json, installedIds: installed);
  }

  /// Auto-install the bundled defaults (MacQul, አመት, KJV) only — not every pack.
  Future<void> ensurePreferredInstalled(
    BibleCatalog catalog, {
    String? preferredId,
  }) async {
    final ids = List<String>.from(catalog.defaultTranslationIds);
    if (ids.isEmpty) return;

    // Prefer installing the restored session translation first when it is a default.
    if (preferredId != null && ids.contains(preferredId)) {
      ids.remove(preferredId);
      ids.insert(0, preferredId);
    }

    for (final id in ids) {
      await _ensureInstalled(catalog, id);
    }
  }

  Future<void> _ensureInstalled(BibleCatalog catalog, String id) async {
    final version = catalog.translations.firstWhere(
      (t) => t.id == id,
      orElse: () => throw StateError('Missing translation $id'),
    );

    final hasMeta = await _db.isTranslationInstalled(id);
    final hasContent = hasMeta && await _db.hasTranslationContent(id);
    if (hasContent && !await _needsRepair(version)) return;

    await installVersion(version);
  }

  /// Detect stale / wrong-language installs (e.g. old Amharic data under macqul).
  Future<bool> _needsRepair(BibleVersion version) async {
    final counts = await _db.translationContentCounts(version.id);
    if (version.bookCount > 0 && counts.books != version.bookCount) {
      return true;
    }
    if (version.verseCount > 0 && counts.verses != version.verseCount) {
      return true;
    }

    final isOromo = version.id == 'macqul' ||
        version.languageCode == 'om' ||
        version.language.toLowerCase().contains('orom');
    if (!isOromo) return false;

    final sample = await _db.getSampleVerse(version.id);
    final haystack = '${sample.bookName ?? ''} ${sample.text ?? ''}';
    if (haystack.trim().isEmpty) return true;
    // Ethiopic script means Amharic (or Ge'ez) was installed under an Oromo id.
    return RegExp(r'[\u1200-\u137F]').hasMatch(haystack);
  }

  Future<void> installVersion(BibleVersion version) async {
    final pack = await _loadPackFromAsset(version.asset);
    await _db.installTranslationPack(pack);
    await _mirrorPackToDocuments(version.id, pack);
  }

  Future<void> uninstallVersion(BibleVersion version) async {
    if (version.bundled) {
      throw StateError('Bundled default translations cannot be removed');
    }
    await _db.uninstallTranslation(version.id);
    final dir = await _packsDirectory();
    final file = File(p.join(dir.path, '${version.id}.json'));
    if (await file.exists()) await file.delete();
  }

  Future<Map<String, dynamic>> _loadPackFromAsset(String relativeAsset) async {
    final assetPath = 'assets/bible/$relativeAsset';
    final bytes = await rootBundle.load(assetPath);
    final data = Uint8List.fromList(
      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
    final isGzip = relativeAsset.endsWith('.gz');
    return compute(
      _decodePack,
      _DecodeArgs(data: data, gzipped: isGzip),
    );
  }

  static Map<String, dynamic> _decodePack(_DecodeArgs args) {
    final raw = args.gzipped ? gzip.decode(args.data) : args.data;
    final json = jsonDecode(utf8.decode(raw));
    return (json as Map).cast<String, dynamic>();
  }

  Future<Directory> _packsDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'bible_packs'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> _mirrorPackToDocuments(
    String translationId,
    Map<String, dynamic> pack,
  ) async {
    final dir = await _packsDirectory();
    final file = File(p.join(dir.path, '$translationId.json'));
    await file.writeAsString(jsonEncode(pack), flush: true);
  }
}

class _DecodeArgs {
  final Uint8List data;
  final bool gzipped;
  const _DecodeArgs({required this.data, required this.gzipped});
}
