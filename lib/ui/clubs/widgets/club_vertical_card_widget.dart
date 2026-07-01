import 'package:booklub/config/routing/routes.dart';
import 'package:booklub/domain/entities/clubs/club.dart';
import 'package:booklub/ui/core/widgets/safe_network_image.dart';
import 'package:booklub/ui/core/widgets/vertical_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ClubVerticalCardWidget extends StatelessWidget {

  final Club club;

  const ClubVerticalCardWidget({
    super.key,
    required this.club,
  });

  @override
  Widget build(BuildContext context) {
    return VerticalCardWidget(
      imageProvider: safeNetworkImageProvider(club.imageUrl),
      child: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(club.name),
          ],
        ),
      ),
      onTap: () => context.push(Routes.clubProfile(clubId: club.id)),
    );
  }


}
