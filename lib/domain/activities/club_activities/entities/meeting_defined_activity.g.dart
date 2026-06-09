// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_defined_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingDefinedActivity _$MeetingDefinedActivityFromJson(
  Map<String, dynamic> json,
) => MeetingDefinedActivity(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
  clubId: json['clubId'] as String,
  meetingId: json['meetingId'] as String,
  clubName: json['clubName'] as String?,
  clubPhotoUrl: json['clubPhotoUrl'] as String?,
  meetingAddress: json['meetingAddress'] as String?,
  meetingDate:
      json['meetingDate'] == null
          ? null
          : DateTime.parse(json['meetingDate'] as String),
  bookId: json['bookId'] as String?,
  bookTitle: json['bookTitle'] as String?,
  bookCoverUrl: json['bookCoverUrl'] as String?,
);

Map<String, dynamic> _$MeetingDefinedActivityToJson(
  MeetingDefinedActivity instance,
) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'type': _$ActivityTypeEnumMap[instance.type]!,
  'clubId': instance.clubId,
  'clubName': instance.clubName,
  'clubPhotoUrl': instance.clubPhotoUrl,
  'meetingId': instance.meetingId,
  'meetingAddress': instance.meetingAddress,
  'meetingDate': instance.meetingDate?.toIso8601String(),
  'bookId': instance.bookId,
  'bookTitle': instance.bookTitle,
  'bookCoverUrl': instance.bookCoverUrl,
};

const _$ActivityTypeEnumMap = {
  ActivityType.meetingDefined: 'MEETING_DEFINED',
  ActivityType.memberCompletedReading: 'MEMBER_COMPLETED_READING',
  ActivityType.readingGoalDefined: 'READING_GOAL_DEFINED',
  ActivityType.userCompletedReading: 'USER_COMPLETED_READING',
};
