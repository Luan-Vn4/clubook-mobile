// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_goal_with_book.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingGoalWithBook _$ReadingGoalWithBookFromJson(Map<String, dynamic> json) =>
    ReadingGoalWithBook(
      id: json['id'] as String,
      bookId: json['bookId'] as String,
      clubId: json['clubId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      book: BookItem.fromJson(json['book'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReadingGoalWithBookToJson(
  ReadingGoalWithBook instance,
) => <String, dynamic>{
  'id': instance.id,
  'bookId': instance.bookId,
  'clubId': instance.clubId,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'book': instance.book,
};
