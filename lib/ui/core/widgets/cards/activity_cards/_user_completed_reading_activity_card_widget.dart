import 'package:booklub/domain/activities/user_activities/entities/user_completed_reading_activity.dart';
import 'package:booklub/ui/core/widgets/cards/activity_cards/_user_activity_card_widget.dart';
import 'package:flutter/material.dart';

class UserCompletedReadingActivityWidget extends StatelessWidget {

  final UserCompletedReadingActivity activity;

  final bool showUserHeader;

  const UserCompletedReadingActivityWidget({
    super.key,
    required this.activity,
    this.showUserHeader = true,
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

    return UserActivityCardWidget(
      title: 'Atividade: Leitura Concluída',
      activity: activity,
      bookCoverUrl: activity.bookCoverUrl,
      showUserHeader: showUserHeader,
      children: [
        bookInfo,
      ],
    );
  }

}
