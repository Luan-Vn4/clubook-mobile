import 'package:booklub/config/theme/theme_config.dart';
import 'package:booklub/ui/core/widgets/cards/books/horizontal_card_with_book_cover.dart';
import 'package:booklub/ui/core/widgets/circle_image_widget.dart';
import 'package:booklub/ui/core/widgets/safe_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HorizontalUserContentCardWithBookCover extends StatelessWidget {

  final String title;

  final String? userName;

  final String? userAvatarUrl;

  final String? bookCoverUrl;

  final bool showUserHeader;

  final DateTime createdAt;

  final List<Widget> children;

  const HorizontalUserContentCardWithBookCover({
    super.key,
    required this.title,
    this.userName,
    this.userAvatarUrl,
    this.bookCoverUrl,
    required this.createdAt,
    required this.children,
    this.showUserHeader = false
  });

  @override
  Widget build(BuildContext context) {
    return HorizontalCardWithBookCover(
      title: title,
      bookCoverUrl: bookCoverUrl,
      header: Builder(builder: _buildHeader),
      children: children,
    );
  }

  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 8,
      children: [
        if (showUserHeader) Row(
          spacing: 8,
          children: [
            CircleImageWidget(
              borderWidth: 0,
              backgroundColor: colorScheme.white,
              radius: 24,
              decorationImage: userAvatarUrl != null
                ? DecorationImage(
                    image: safeNetworkImageProvider(userAvatarUrl),
                    fit: BoxFit.cover,
                  )
                : null,
            ),
            Text(userName ?? 'Usuário desconhecido', style: textTheme.labelMedium!.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold
            ))
          ]
        ),
        Text(
            DateFormat('dd/MM/yyyy').format(createdAt),
            style: textTheme.labelMedium!.copyWith(
              color: colorScheme.onPrimary,
            )
        ),
      ],
    );
  }

}
