import 'package:json_annotation/json_annotation.dart';

part 'club_pending_request.g.dart';

@JsonSerializable()
class ClubPendingRequest {
  final String userId;
  final String clubId;
  final String entryType;

  const ClubPendingRequest({
    required this.userId,
    required this.clubId,
    required this.entryType,
  });

  factory ClubPendingRequest.fromJson(Map<String, dynamic> json) =>
      _$ClubPendingRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ClubPendingRequestToJson(this);
}
