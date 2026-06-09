// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_completed_reading_activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MemberCompletedReadingActivity _$MemberCompletedReadingActivityFromJson(
  Map<String, dynamic> json,
) => MemberCompletedReadingActivity(
  id: json['id'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
  clubId: json['clubId'] as String,
  userId: json['userId'] as String,
  bookId: json['bookId'] as String,
  clubName: json['clubName'] as String?,
  clubPhotoUrl: json['clubPhotoUrl'] as String?,
  startDate:
      json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
  endDate:
      json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
  userName: json['userName'] as String?,
  userAvatarUrl: json['userAvatarUrl'] as String?,
  bookTitle: json['bookTitle'] as String?,
  bookCoverUrl: json['bookCoverUrl'] as String?,
);

Map<String, dynamic> _$MemberCompletedReadingActivityToJson(
  MemberCompletedReadingActivity instance,
) => <String, dynamic>{
  'id': instance.id,
  'createdAt': instance.createdAt.toIso8601String(),
  'type': _$ActivityTypeEnumMap[instance.type]!,
  'clubId': instance.clubId,
  'clubName': instance.clubName,
  'clubPhotoUrl': instance.clubPhotoUrl,
  'userId': instance.userId,
  'bookId': instance.bookId,
  'startDate': instance.startDate?.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'userName': instance.userName,
  'userAvatarUrl': instance.userAvatarUrl,
  'bookTitle': instance.bookTitle,
  'bookCoverUrl': instance.bookCoverUrl,
};

const _$ActivityTypeEnumMap = {
  ActivityType.meetingDefined: 'MEETING_DEFINED',
  ActivityType.memberCompletedReading: 'MEMBER_COMPLETED_READING',
  ActivityType.readingGoalDefined: 'READING_GOAL_DEFINED',
  ActivityType.userCompletedReading: 'USER_COMPLETED_READING',
};
