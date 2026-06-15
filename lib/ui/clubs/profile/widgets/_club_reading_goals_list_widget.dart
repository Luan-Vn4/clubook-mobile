import 'package:booklub/config/routing/routes.dart';
import 'package:booklub/domain/reading_goals/entities/reading_goal_with_book.dart';
import 'package:booklub/ui/clubs/profile/view_models/club_profile_view_model.dart';
import 'package:booklub/ui/core/widgets/grids/infinite_grid_widget.dart';
import 'package:booklub/utils/async_builder.dart';
import 'package:booklub/utils/pagination/paginator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ClubReadingGoalsListWidget extends StatelessWidget {
  const ClubReadingGoalsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ClubProfileViewModel>();

    return AsyncBuilder(
      future: viewModel.getClubReadingGoalsWithBooks(8),
      onRetrieved: (paginator) => Builder(
        builder: (ctx) => onRetrieved(ctx, paginator),
      ),
      onLoading: () => Builder(builder: onLoading),
      onError: (error, stackTrace) => Builder(
        builder: (ctx) => onError(ctx, error, stackTrace),
      ),
    );
  }

  Widget onRetrieved(BuildContext context, Paginator<ReadingGoalWithBook> paginator) {
    final scrollController = context.read<ScrollController>();

    final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 1,
      childAspectRatio: 16 / 5,
      mainAxisSpacing: 12,
    );

    SliverChildBuilderDelegate childrenDelegateProvider(
      List<ReadingGoalWithBook> goals,
      int totalGoals,
    ) =>
        SliverChildBuilderDelegate(
          (context, index) => _ClubReadingGoalCard(goal: goals[index]),
          childCount: totalGoals,
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
        child: Text('Erro ao carregar metas de leitura do clube'),
      ),
    );
  }
}

class _ClubReadingGoalCard extends StatelessWidget {
  final ReadingGoalWithBook goal;

  const _ClubReadingGoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    void onTap() => context.push(
          Routes.individualBook(bookId: goal.bookId),
        );

    final thumbnailUrl = goal.book.thumbnail;

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      child: Card(
        shape: border,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                    ? Image.network(
                        thumbnailUrl,
                        width: 48,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 48,
                            height: 72,
                            color: colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.menu_book,
                              size: 32,
                              color: colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: 48,
                        height: 72,
                        color: colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.menu_book,
                          size: 32,
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      goal.book.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (goal.book.authors != null && goal.book.authors!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        goal.book.authors!,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(goal.startDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '→',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(goal.endDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
