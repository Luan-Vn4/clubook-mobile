import 'package:booklub/domain/activities/entities/activity.dart';
import 'package:booklub/domain/activities/club_activities/entities/club_activity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_defined_activity.g.dart';

@JsonSerializable()
class MeetingDefinedActivity extends ClubActivity {

  final String meetingId;

  final String? meetingAddress;

  final DateTime? meetingDate;

  final String? bookId;

  final String? bookTitle;

  final String? bookCoverUrl;

  MeetingDefinedActivity({
    required super.id,
    required super.createdAt,
    required super.type,
    required super.clubId,
    required this.meetingId,
    super.clubName,
    super.clubPhotoUrl,
    this.meetingAddress,
    this.meetingDate,
    this.bookId,
    this.bookTitle,
    this.bookCoverUrl,
  });

  factory MeetingDefinedActivity.fromJson(Map<String, dynamic> json)  => _$MeetingDefinedActivityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MeetingDefinedActivityToJson(this);

}