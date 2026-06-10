
import 'package:booklub/utils/geo/types/latlng.dart';
import 'package:json_annotation/json_annotation.dart';

part 'meeting_creation_dto.g.dart';

@JsonSerializable()
class MeetingCreationDto {
  final String readingGoalId;
  final String address;
  final LatLng latlng;

  MeetingCreationDto({
    required this.readingGoalId,
    required this.address,
    required this.latlng,
  });

  factory MeetingCreationDto.fromJson(Map<String, dynamic> json) =>
      _$MeetingCreationDtoFromJson(json);
  
  Map<String, dynamic> toJson() => _$MeetingCreationDtoToJson(this);
}