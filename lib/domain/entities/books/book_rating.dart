/// A user's review of a book: a star rating (0-5) and an optional written
/// review (resenha).
class BookRating {
  final String userId;

  final String bookId;

  final int rating;

  final int difficulty;

  final String? review;

  final DateTime createdAt;

  const BookRating({
    required this.userId,
    required this.bookId,
    required this.rating,
    required this.difficulty,
    required this.review,
    required this.createdAt,
  });

  factory BookRating.fromJson(Map<String, dynamic> json) => BookRating(
    userId: json['userId'] as String,
    bookId: json['bookId'] as String,
    rating: (json['rating'] as num?)?.toInt() ?? 0,
    difficulty: (json['difficulty'] as num?)?.toInt() ?? 0,
    review: json['review'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}