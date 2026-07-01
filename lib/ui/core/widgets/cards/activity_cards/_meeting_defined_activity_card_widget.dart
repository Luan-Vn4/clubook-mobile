import 'package:booklub/domain/activities/club_activities/entities/meeting_defined_activity.dart';
import 'package:booklub/ui/core/widgets/cards/activity_cards/_club_activity_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeetingDefinedActivityCardWidget extends StatelessWidget {
  final MeetingDefinedActivity activity;

  final bool showClubHeader;

  const MeetingDefinedActivityCardWidget({
    super.key,
    required this.activity,
    this.showClubHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final bookTitle = activity.bookTitle ?? 'Livro indisponível';

    final meetingDate = Row(
      spacing: 8,
      children: [
        Icon(Icons.calendar_today_rounded),
        Expanded(
          child: Text(
            activity.meetingDate != null
                ? DateFormat('dd/MM/yyyy HH:mm').format(activity.meetingDate!)
                : 'Data indisponível',
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );

    final address = Row(
      spacing: 8,
      children: [
        Icon(Icons.location_on_rounded),
        Expanded(
          child: Text(
            activity.meetingAddress ?? 'Endereço indisponível',
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );

    final readingGoalBook = Row(
      spacing: 8,
      children: [
        Icon(Icons.menu_book_rounded),
        Expanded(
          child: Text(
            bookTitle,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );

    return ClubActivityCardWidget(
      title: 'Atividade: Encontro Definido',
      activity: activity,
      clubName: activity.clubName,
      clubPhotoUrl: activity.clubPhotoUrl,
      bookCoverUrl: activity.bookCoverUrl,
      showClubHeader: showClubHeader,
      children: [
        meetingDate,
        address,
        readingGoalBook,
      ],
    );
  }
}
