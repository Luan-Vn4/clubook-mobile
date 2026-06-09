import 'package:booklub/domain/activities/entities/activity.dart';

abstract class ClubActivity extends Activity {

  final String clubId;

  final String? clubName;

  final String? clubPhotoUrl;

  ClubActivity({
    required super.id,
    required super.createdAt,
    required super.type,
    required this.clubId,
    this.clubName,
    this.clubPhotoUrl,
  });

}