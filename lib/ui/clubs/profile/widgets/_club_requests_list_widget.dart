import 'package:booklub/config/theme/theme_config.dart';
import 'package:booklub/domain/clubs/entities/club_pending_request.dart';
import 'package:booklub/ui/clubs/profile/view_models/club_profile_view_model.dart';
import 'package:booklub/ui/core/widgets/circle_image_widget.dart';
import 'package:booklub/ui/core/widgets/grids/infinite_grid_widget.dart';
import 'package:booklub/utils/async_builder.dart';
import 'package:booklub/utils/pagination/paginator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClubRequestsListWidget extends StatelessWidget {
  const ClubRequestsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ClubProfileViewModel>();

    return AsyncBuilder(
      future: viewModel.getClubPendingRequests(8),
      onRetrieved: (paginator) => Builder(
        builder: (ctx) => onRetrieved(ctx, paginator, viewModel),
      ),
      onLoading: () => Builder(builder: onLoading),
      onError: (error, stackTrace) => Builder(
        builder: (ctx) => onError(ctx, error, stackTrace),
      ),
    );
  }

  Widget onRetrieved(
    BuildContext context,
    Paginator<dynamic> paginator,
    ClubProfileViewModel viewModel,
  ) {
    final scrollController = context.read<ScrollController>();

    final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 1,
      childAspectRatio: 9 / 2.5,
      mainAxisSpacing: 12,
    );

    SliverChildBuilderDelegate childrenDelegateProvider(
      List<dynamic> requests,
      int totalRequests,
    ) =>
        SliverChildBuilderDelegate(
          (context, index) {
            final request = requests[index] as ClubPendingRequest;
            return _ClubRequestCard(
              request: request,
              onAccept: () => viewModel.acceptRequest(request.userId),
              onDeny: () => viewModel.denyRequest(request.userId),
            );
          },
          childCount: totalRequests,
        );

    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 12,
        left: 12,
        right: 12,
        bottom: 36,
      ),
      sliver: InfiniteGridWidget.sliver(
        paginator: paginator,
        controller: scrollController,
        gridDelegate: gridDelegate,
        childrenDelegateProvider: childrenDelegateProvider,
      ),
    );
  }

  Widget onLoading(BuildContext context) {
    return const SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget onError(BuildContext context, Object error, StackTrace stackTrace) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Text('Erro ao carregar solicitações do clube'),
      ),
    );
  }
}

class _ClubRequestCard extends StatelessWidget {
  final ClubPendingRequest request;
  final VoidCallback onAccept;
  final VoidCallback onDeny;

  const _ClubRequestCard({
    required this.request,
    required this.onAccept,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(100),
        topRight: const Radius.circular(36),
        bottomLeft: const Radius.circular(100),
        bottomRight: const Radius.circular(36),
      ),
    );

    return Card(
      shape: border,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            CircleImageWidget.expanded(
              backgroundColor: colorScheme.white,
              borderColor: colorScheme.primary,
              borderWidth: 2,
              decorationImage: null, // User has no image in pending request
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    request.userId,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Solicitação de entrada',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: onAccept,
              icon: const Icon(Icons.check),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 4),
            IconButton.filled(
              onPressed: onDeny,
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
