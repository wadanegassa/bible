class BibleVersion {
  final String id;
  final String name;
  final String fullname;
  final String language;
  final bool isDownloaded;
  final String? localPath;

  BibleVersion({
    required this.id,
    required this.name,
    required this.fullname,
    required this.language,
    this.isDownloaded = false,
    this.localPath,
  });

  BibleVersion copyWith({
    bool? isDownloaded,
    String? localPath,
  }) {
    return BibleVersion(
      id: id,
      name: name,
      fullname: fullname,
      language: language,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localPath: localPath ?? this.localPath,
    );
  }
}
