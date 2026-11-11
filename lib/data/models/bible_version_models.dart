class BibleLicense {
  final String type;
  final bool commercialUse;
  final String? url;

  const BibleLicense({
    required this.type,
    required this.commercialUse,
    this.url,
  });

  factory BibleLicense.fromJson(Map<String, dynamic> json) {
    return BibleLicense(
      type: json['type']?.toString() ?? 'unknown',
      commercialUse: json['commercialUse'] == true,
      url: json['url']?.toString(),
    );
  }
}

class BibleVersion {
  final String id;
  final String name;
  final String fullname;
  final String language;
  final String languageCode;
  final String? dialect;
  final String shortName;
  final String? publisher;
  final int? year;
  final BibleLicense license;
  final String attribution;
  final String scope;
  final String? script;
  final String? canon;
  final String textDirection;
  final String source;
  final String asset;
  final bool bundled;
  final bool isDownloaded;
  final int bookCount;
  final int verseCount;
  final int sizeBytes;

  const BibleVersion({
    required this.id,
    required this.name,
    required this.fullname,
    required this.language,
    required this.languageCode,
    required this.shortName,
    required this.license,
    required this.attribution,
    required this.scope,
    required this.source,
    required this.asset,
    required this.bundled,
    required this.bookCount,
    required this.verseCount,
    required this.sizeBytes,
    this.script,
    this.canon,
    this.textDirection = 'ltr',
    this.dialect,
    this.publisher,
    this.year,
    this.isDownloaded = false,
  });

  factory BibleVersion.fromCatalogJson(
    Map<String, dynamic> json, {
    bool isDownloaded = false,
  }) {
    final licenseJson = (json['license'] as Map?)?.cast<String, dynamic>() ?? {};
    return BibleVersion(
      id: json['id'] as String,
      name: (json['shortName'] ?? json['name']).toString(),
      fullname: json['name']?.toString() ?? '',
      language: json['languageName']?.toString() ?? '',
      languageCode: json['language']?.toString() ?? '',
      dialect: json['dialect']?.toString(),
      shortName: json['shortName']?.toString() ?? json['id'].toString(),
      publisher: json['publisher']?.toString(),
      year: json['year'] is int ? json['year'] as int : int.tryParse('${json['year']}'),
      license: BibleLicense.fromJson(licenseJson),
      attribution: json['attribution']?.toString() ?? '',
      scope: json['scope']?.toString() ?? 'full',
      script: json['script']?.toString(),
      canon: json['canon']?.toString(),
      textDirection: json['textDirection']?.toString() ?? 'ltr',
      source: json['source']?.toString() ?? '',
      asset: json['asset']?.toString() ?? '',
      bundled: json['bundled'] == true,
      isDownloaded: isDownloaded,
      bookCount: json['bookCount'] is int ? json['bookCount'] as int : 0,
      verseCount: json['verseCount'] is int ? json['verseCount'] as int : 0,
      sizeBytes: json['sizeBytes'] is int ? json['sizeBytes'] as int : 0,
    );
  }

  BibleVersion copyWith({bool? isDownloaded}) {
    return BibleVersion(
      id: id,
      name: name,
      fullname: fullname,
      language: language,
      languageCode: languageCode,
      dialect: dialect,
      shortName: shortName,
      publisher: publisher,
      year: year,
      license: license,
      attribution: attribution,
      scope: scope,
      script: script,
      canon: canon,
      textDirection: textDirection,
      source: source,
      asset: asset,
      bundled: bundled,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      bookCount: bookCount,
      verseCount: verseCount,
      sizeBytes: sizeBytes,
    );
  }

  String get scopeLabel {
    switch (scope) {
      case 'nt':
        return 'New Testament';
      case 'ot':
        return 'Old Testament';
      case 'partial':
        return 'Partial';
      default:
        return 'Full Bible';
    }
  }

  String get sizeLabel {
    if (sizeBytes <= 0) return '';
    final mb = sizeBytes / (1024 * 1024);
    if (mb >= 1) return '${mb.toStringAsFixed(1)} MB';
    return '${(sizeBytes / 1024).round()} KB';
  }
}

class BibleCatalog {
  final int schemaVersion;
  final List<String> defaultTranslationIds;
  final List<BibleVersion> translations;
  final List<Map<String, dynamic>> languages;
  final List<String> notes;

  const BibleCatalog({
    required this.schemaVersion,
    required this.defaultTranslationIds,
    required this.translations,
    required this.languages,
    required this.notes,
  });

  factory BibleCatalog.fromJson(
    Map<String, dynamic> json, {
    Set<String> installedIds = const {},
  }) {
    final translations = (json['translations'] as List? ?? [])
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .map(
          (item) => BibleVersion.fromCatalogJson(
            item,
            // Bundled defaults ship in the APK — treat as installed (no download UI).
            isDownloaded: installedIds.contains(item['id']) ||
                item['bundled'] == true,
          ),
        )
        .toList();

    return BibleCatalog(
      schemaVersion: json['schemaVersion'] is int ? json['schemaVersion'] as int : 1,
      defaultTranslationIds: (json['defaultTranslationIds'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      translations: translations,
      languages: (json['languages'] as List? ?? [])
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .toList(),
      notes: (json['notes'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }
}
