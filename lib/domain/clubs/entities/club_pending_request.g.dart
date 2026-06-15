// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'club_pending_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClubPendingRequest _$ClubPendingRequestFromJson(Map<String, dynamic> json) =>
    ClubPendingRequest(
      userId: json['userId'] as String,
      clubId: json['clubId'] as String,
      entryType: json['entryType'] as String,
    );

Map<String, dynamic> _$ClubPendingRequestToJson(ClubPendingRequest instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'clubId': instance.clubId,
      'entryType': instance.entryType,
    };
