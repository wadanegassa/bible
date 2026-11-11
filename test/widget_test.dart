import 'package:flutter_test/flutter_test.dart';
import 'package:amharicbible/data/models/bible_version_models.dart';

void main() {
  test('BibleVersion catalog parsing marks download state', () {
    final version = BibleVersion.fromCatalogJson({
      'id': 'gaz',
      'language': 'om',
      'languageName': 'Afaan Oromoo',
      'name': 'Open New Oromo Contemporary Version',
      'shortName': 'ONCV',
      'license': {'type': 'CC-BY-SA-4.0', 'commercialUse': true},
      'attribution': 'Biblica',
      'scope': 'full',
      'source': 'eBible.org',
      'asset': 'bundled/gaz.json',
      'bundled': true,
      'bookCount': 66,
      'verseCount': 31101,
      'sizeBytes': 1000,
    }, isDownloaded: true);

    expect(version.id, 'gaz');
    expect(version.isDownloaded, isTrue);
    expect(version.bundled, isTrue);
    expect(version.license.commercialUse, isTrue);
  });
}
