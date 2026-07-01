/// Aggregated club reading stats for a book.
class BookClubStats {
  /// Clubs whose reading goal for this book has already ended.
  final int alreadyRead;

  /// Clubs whose reading goal for this book is currently active.
  final int currentlyReading;

  const BookClubStats({
    required this.alreadyRead,
    required this.currentlyReading,
  });

  factory BookClubStats.fromJson(Map<String, dynamic> json) => BookClubStats(
    alreadyRead: (json['alreadyRead'] as num?)?.toInt() ?? 0,
    currentlyReading: (json['currentlyReading'] as num?)?.toInt() ?? 0,
  );
}