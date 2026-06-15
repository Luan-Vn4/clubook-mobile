import 'package:booklub/domain/activities/club_activities/entities/member_completed_reading_activity.dart';
import 'package:booklub/ui/core/widgets/cards/activity_cards/_club_activity_card_widget.dart';
import 'package:flutter/material.dart';

class MemberCompletedReadingActivityCardWidget extends StatelessWidget {

  final MemberCompletedReadingActivity activity;

  final bool showClubHeader;

  const MemberCompletedReadingActivityCardWidget({
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

    final userInfo = Row(
      spacing: 8,
      children: [
        Icon(Icons.person_rounded),
        Expanded(
          child: Text(
            activity.userName ?? 'Usuário desconhecido',
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    );

    return ClubActivityCardWidget(
      title: 'Atividade: Leitura Concluída por Membro',
      activity: activity,
      clubName: activity.clubName,
      clubPhotoUrl: activity.clubPhotoUrl,
      bookCoverUrl: activity.bookCoverUrl,
      showClubHeader: showClubHeader,
      children: [
        bookInfo,
        userInfo,
      ],
    );
  }

}
