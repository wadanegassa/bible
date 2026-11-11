import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catalog and bundled packs are complete', () {
    final catalogFile = File('assets/bible/catalog.json');
    expect(catalogFile.existsSync(), isTrue);

    final catalog = jsonDecode(catalogFile.readAsStringSync()) as Map<String, dynamic>;
    final defaults = (catalog['defaultTranslationIds'] as List).cast<String>();
    expect(defaults, ['macqul', 'nasv', 'engkjv']);

    final translations = (catalog['translations'] as List).cast<Map<String, dynamic>>();
    expect(translations.length, greaterThanOrEqualTo(30));
    final languages = (catalog['languages'] as List).cast<Map<String, dynamic>>();
    expect(languages.length, greaterThanOrEqualTo(15));

    final byId = {
      for (final t in translations) t['id'] as String: t,
    };
    for (final id in ['macqul', 'nasv', 'engkjv', 'am54', 'am05', 'am2005', 'am2000']) {
      expect(byId.containsKey(id), isTrue, reason: 'missing catalog id $id');
    }
    expect(byId.containsKey('niv'), isFalse);

    for (final id in defaults) {
      final meta = byId[id]!;
      expect(meta['bundled'], isTrue, reason: '$id should be bundled');
      final packFile = File('assets/bible/bundled/$id.json');
      expect(packFile.existsSync(), isTrue, reason: 'missing bundled pack $id');
      final pack =
          jsonDecode(packFile.readAsStringSync()) as Map<String, dynamic>;
      final books = pack['books'] as List;
      expect(books.length, greaterThanOrEqualTo(65), reason: '$id should have a full canon');
      expect(pack['verseCount'], greaterThan(30000));

      final gen = books.firstWhere((b) => b['id'] == 'GEN') as Map<String, dynamic>;
      final verse1 = (((gen['chapters'] as List).first as Map)['verses'] as List).first
          as Map<String, dynamic>;
      expect((verse1['text'] as String).isNotEmpty, isTrue);
    }

    for (final optional in [
      'am54',
      'am05',
      'am2005',
      'am2000',
      'gax',
      'gaze',
      'ti',
      'som',
      'dwrENT',
      'gmve',
      'gofe',
      'mdyeth',
      'wal',
      'sid',
      'hdy',
      'nus',
      'grclxx',
      'hebwlc',
      'latclem',
      'grctr',
      'engbrent',
    ]) {
      expect(
        File('assets/bible/optional/$optional.json.gz').existsSync(),
        isTrue,
        reason: 'missing optional pack $optional',
      );
    }
  });
}
