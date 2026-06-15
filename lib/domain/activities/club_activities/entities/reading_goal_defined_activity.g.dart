// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_goal_defined_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadingGoalDefinedActivity _$ReadingGoalDefinedActivityFromJson(
  Map<String, dynamic> json,
) => ReadingGoalDefinedActivity(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
  clubId: json['clubId'] as String,
  readingGoalId: json['readingGoalId'] as String,
  clubName: json['clubName'] as String?,
  clubPhotoUrl: json['clubPhotoUrl'] as String?,
  goalStartDate:
      json['goalStartDate'] == null
          ? null
          : DateTime.parse(json['goalStartDate'] as String),
  goalEndDate:
      json['goalEndDate'] == null
          ? null
          : DateTime.parse(json['goalEndDate'] as String),
  bookTitle: json['bookTitle'] as String?,
  bookCoverUrl: json['bookCoverUrl'] as String?,
);

Map<String, dynamic> _$ReadingGoalDefinedActivityToJson(
  ReadingGoalDefinedActivity instance,
) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'type': _$ActivityTypeEnumMap[instance.type]!,
  'clubId': instance.clubId,
  'clubName': instance.clubName,
  'clubPhotoUrl': instance.clubPhotoUrl,
  'readingGoalId': instance.readingGoalId,
  'goalStartDate': instance.goalStartDate?.toIso8601String(),
  'goalEndDate': instance.goalEndDate?.toIso8601String(),
  'bookTitle': instance.bookTitle,
  'bookCoverUrl': instance.bookCoverUrl,
};

const _$ActivityTypeEnumMap = {
  ActivityType.meetingDefined: 'MEETING_DEFINED',
  ActivityType.memberCompletedReading: 'MEMBER_COMPLETED_READING',
  ActivityType.readingGoalDefined: 'READING_GOAL_DEFINED',
  ActivityType.userCompletedReading: 'USER_COMPLETED_READING',
};
