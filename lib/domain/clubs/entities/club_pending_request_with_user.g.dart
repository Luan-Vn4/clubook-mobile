// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_pending_request_with_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClubPendingRequestWithUser _$ClubPendingRequestWithUserFromJson(
  Map<String, dynamic> json,
) => ClubPendingRequestWithUser(
  userId: json['userId'] as String,
  clubId: json['clubId'] as String,
  entryType: json['entryType'] as String,
  user: User.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ClubPendingRequestWithUserToJson(
  ClubPendingRequestWithUser instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'clubId': instance.clubId,
  'entryType': instance.entryType,
  'user': instance.user,
};
