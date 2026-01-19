class Book {
  final String id; // Book ID like "GEN"
  final String name;
  final int chapterCount;

  Book({
    required this.id,
    required this.name,
    required this.chapterCount,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      name: json['name'],
      chapterCount: json['chapterCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      name: map['name'],
      chapterCount: 0, // Not stored in DB
    );
  }
}

class Chapter {
  final int number;
  final String bookId;

  Chapter({
    required this.number,
    required this.bookId,
  });
}

class Verse {
  final int? dbId;
  final String bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final bool isBookmarked;

  Verse({
    this.dbId,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    this.isBookmarked = false,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      bookId: json['book_id'],
      bookName: json['book_name'],
      chapter: json['chapter'],
      verse: json['verse'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'book_id': bookId,
      'book_name': bookName,
      'chapter': chapter,
      'verse': verse,
      'text': text,
      'is_bookmarked': isBookmarked ? 1 : 0,
    };
  }

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(
      dbId: map['db_id'],
      bookId: map['book_id'],
      bookName: map['book_name'],
      chapter: map['chapter'],
      verse: map['verse'],
      text: map['text'],
      isBookmarked: map['is_bookmarked'] == 1,
    );
  }

  Verse copyWith({bool? isBookmarked}) {
    return Verse(
      dbId: dbId,
      bookId: bookId,
      bookName: bookName,
      chapter: chapter,
      verse: verse,
      text: text,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }

  String get id => '$bookId.$chapter.$verse';
  String get reference => '$bookName $chapter:$verse';
}
