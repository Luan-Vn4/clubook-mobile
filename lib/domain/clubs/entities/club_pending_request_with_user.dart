import 'package:booklub/domain/entities/users/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'club_pending_request_with_user.g.dart';

@JsonSerializable()
class ClubPendingRequestWithUser {
  final String userId;
  final String clubId;
  final String entryType;
  final User user;

  const ClubPendingRequestWithUser({
    required this.userId,
    required this.clubId,
    required this.entryType,
    required this.user,
  });

  factory ClubPendingRequestWithUser.fromJson(Map<String, dynamic> json) =>
      _$ClubPendingRequestWithUserFromJson(json);

  Map<String, dynamic> toJson() => _$ClubPendingRequestWithUserToJson(this);
}
