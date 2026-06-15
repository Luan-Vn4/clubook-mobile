import 'package:booklub/domain/activities/entities/activity.dart';
import 'package:booklub/domain/activities/user_activities/entities/user_activity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_completed_reading_activity.g.dart';

@JsonSerializable()
class UserCompletedReadingActivity extends UserActivity {

  final String bookId;

  final DateTime? startDate;

  final DateTime? endDate;

  final String? bookTitle;

  final String? bookCoverUrl;

  UserCompletedReadingActivity({
    required super.id,
    required super.createdAt,
    required super.type,
    required super.userId,
    required this.bookId,
    this.startDate,
    this.endDate,
    this.bookTitle,
    this.bookCoverUrl,
  });

  factory UserCompletedReadingActivity.fromJson(Map<String, dynamic> json) =>
      _$UserCompletedReadingActivityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserCompletedReadingActivityToJson(this);
}
