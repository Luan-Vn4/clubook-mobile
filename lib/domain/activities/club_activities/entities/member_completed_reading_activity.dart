import 'package:booklub/domain/activities/entities/activity.dart';
import 'package:json_annotation/json_annotation.dart';

import 'club_activity.dart';

part 'member_completed_reading_activity.g.dart';

@JsonSerializable()
class MemberCompletedReadingActivity extends ClubActivity {

  final String userId;

  final String bookId;

  final DateTime? startDate;

  final DateTime? endDate;

  final String? userName;

  final String? userAvatarUrl;

  final String? bookTitle;

  final String? bookCoverUrl;

  MemberCompletedReadingActivity({
    required super.id,
    required super.createdAt,
    required super.type,
    required super.clubId,
    required this.userId,
    required this.bookId,
    super.clubName,
    super.clubPhotoUrl,
    this.startDate,
    this.endDate,
    this.userName,
    this.userAvatarUrl,
    this.bookTitle,
    this.bookCoverUrl,
  });

  factory MemberCompletedReadingActivity.fromJson(Map<String, dynamic> json) =>
      _$MemberCompletedReadingActivityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MemberCompletedReadingActivityToJson(this);
}