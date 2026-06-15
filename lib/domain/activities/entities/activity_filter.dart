import 'package:booklub/domain/activities/entities/activity.dart';

/// Filter categories for the club activities feed.
///
/// Maps user-facing tab labels to server-side [ActivityType] lists.
enum ActivityFilter {

  /// Show all activity types (no filter sent to API).
  all,

  /// Show reading-related activities.
  readings,

  /// Show meeting-related activities.
  meetings;

  /// Converts this filter to a list of [ActivityType] for API calls.
  ///
  /// Returns `null` when no filtering is needed (i.e. [all]).
  List<ActivityType>? toActivityTypes() => switch (this) {
    ActivityFilter.all => null,
    ActivityFilter.readings => [
      ActivityType.memberCompletedReading,
      ActivityType.readingGoalDefined,
    ],
    ActivityFilter.meetings => [ActivityType.meetingDefined],
  };

}
