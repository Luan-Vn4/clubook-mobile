import 'package:booklub/domain/activities/club_activities/entities/reading_goal_defined_activity.dart';
import 'package:booklub/ui/core/widgets/cards/activity_cards/_club_activity_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReadingGoalDefinedActivityCardWidget extends StatelessWidget {

  final ReadingGoalDefinedActivity activity;

  final bool showClubHeader;

  const ReadingGoalDefinedActivityCardWidget({
    super.key,
    required this.activity,
    this.showClubHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final bookTitle = activity.bookTitle ?? 'Livro indisponível';

    final bookInfo = Row(
      spacing: 8,
      children: [
        Icon(Icons.menu_book_rounded),
        Expanded(
          child: Text(
            bookTitle,
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    );

    final schedule = Row(
      spacing: 8,
      children: [
        Icon(Icons.calendar_month_rounded),
        if (activity.goalStartDate != null && activity.goalEndDate != null) ...[
          Text(DateFormat('dd/MM/yyyy').format(activity.goalStartDate!)),
          Icon(Icons.arrow_forward_rounded, size: 16),
          Text(DateFormat('dd/MM/yyyy').format(activity.goalEndDate!)),
        ],
      ],
    );

    return ClubActivityCardWidget(
      title: 'Atividade: Meta de Leitura Definida',
      activity: activity,
      clubName: activity.clubName,
      clubPhotoUrl: activity.clubPhotoUrl,
      bookCoverUrl: activity.bookCoverUrl,
      showClubHeader: showClubHeader,
      children: [
        bookInfo,
        schedule,
      ],
    );
  }

}
