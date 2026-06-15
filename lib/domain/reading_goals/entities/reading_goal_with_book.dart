import 'package:booklub/domain/entities/books/book_item.dart';
import 'package:booklub/domain/reading_goals/entities/reading_goal.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reading_goal_with_book.g.dart';

@JsonSerializable()
class ReadingGoalWithBook {
  final String id;
  final String bookId;
  final String clubId;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final BookItem book;

  const ReadingGoalWithBook({
    required this.id,
    required this.bookId,
    required this.clubId,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.book,
  });

  factory ReadingGoalWithBook.fromReadingGoal(
    ReadingGoal goal,
    BookItem book,
  ) {
    return ReadingGoalWithBook(
      id: goal.id,
      bookId: goal.bookId,
      clubId: goal.clubId,
      startDate: goal.startDate,
      endDate: goal.endDate,
      createdAt: goal.createdAt,
      book: book,
    );
  }

  factory ReadingGoalWithBook.fromJson(Map<String, dynamic> json) =>
      _$ReadingGoalWithBookFromJson(json);

  Map<String, dynamic> toJson() => _$ReadingGoalWithBookToJson(this);
}
