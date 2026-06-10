// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meeting_creation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeetingCreationDto _$MeetingCreationDtoFromJson(Map<String, dynamic> json) =>
    MeetingCreationDto(
      readingGoalId: json['readingGoalId'] as String,
      address: json['address'] as String,
      latlng: LatLng.fromJson(json['latlng'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MeetingCreationDtoToJson(MeetingCreationDto instance) =>
    <String, dynamic>{
      'readingGoalId': instance.readingGoalId,
      'address': instance.address,
      'latlng': instance.latlng,
    };
