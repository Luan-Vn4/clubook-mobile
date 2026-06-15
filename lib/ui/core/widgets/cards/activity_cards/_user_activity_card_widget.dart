import 'package:booklub/domain/activities/entities/activity.dart';
import 'package:booklub/ui/core/widgets/cards/users/horizontal_user_content_card_with_book_cover.dart';
import 'package:flutter/material.dart';

class UserActivityCardWidget extends StatelessWidget {

  final String title;

  final Activity activity;

  final String? userName;

  final String? userAvatarUrl;

  final String? bookCoverUrl;

  final bool showUserHeader;

  final List<Widget> children;

  const UserActivityCardWidget({
    super.key,
    required this.title,
    required this.activity,
    this.userName,
    this.userAvatarUrl,
    this.bookCoverUrl,
    required this.children,
    this.showUserHeader = false,
  });

  @override
  Widget build(BuildContext context) {

    return HorizontalUserContentCardWithBookCover(
        title: title,
        userName: userName,
        userAvatarUrl: userAvatarUrl,
        bookCoverUrl: bookCoverUrl,
        createdAt: activity.createdAt,
        showUserHeader: showUserHeader,
        children: children
    );
  }

}