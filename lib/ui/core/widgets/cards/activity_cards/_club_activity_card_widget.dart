import 'package:booklub/domain/activities/entities/activity.dart';
import 'package:booklub/ui/core/widgets/cards/clubs/horizontal_club_content_card_with_book_cover.dart';
import 'package:flutter/material.dart';

class ClubActivityCardWidget extends StatelessWidget {

  final String title;

  final Activity activity;

  final String? clubName;

  final String? clubPhotoUrl;

  final String? bookCoverUrl;

  final bool showClubHeader;

  final List<Widget> children;

  const ClubActivityCardWidget({
    super.key,
    required this.title,
    required this.activity,
    this.clubName,
    this.clubPhotoUrl,
    this.bookCoverUrl,
    required this.children,
    this.showClubHeader = false,
  });

  @override
  Widget build(BuildContext context) {

    return HorizontalClubContentCardWithBookCover(
        title: title,
        clubName: clubName,
        clubPhotoUrl: clubPhotoUrl,
        bookCoverUrl: bookCoverUrl,
        createdAt: activity.createdAt,
        showClubHeader: showClubHeader,
        children: children
    );
  }

}
