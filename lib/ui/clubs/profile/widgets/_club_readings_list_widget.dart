import 'package:booklub/config/routing/routes.dart';
import 'package:booklub/domain/entities/books/book_item.dart';
import 'package:booklub/domain/reading_goals/entities/reading_goal.dart';
import 'package:booklub/infra/books/book_api_repository.dart';
import 'package:booklub/ui/clubs/profile/view_models/club_profile_view_model.dart';
import 'package:booklub/ui/core/widgets/grids/infinite_grid_widget.dart';
import 'package:booklub/ui/core/widgets/safe_network_image.dart';
import 'package:booklub/utils/async_builder.dart';
import 'package:booklub/utils/pagination/paginator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ClubReadingsListWidget extends StatelessWidget {

  const ClubReadingsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ClubProfileViewModel>();

    return AsyncBuilder(
      future: viewModel.getClubReadingGoals(8),
      onRetrieved: (paginator) => Builder(
        builder: (ctx) => onRetrieved(ctx, paginator)
      ),
      onLoading: () => Builder(
        builder: onLoading
      ),
      onError: (error, stackTrace) => Builder(
        builder: (ctx) => onError(ctx, error, stackTrace)
      ),
    );
  }

  Widget onRetrieved(BuildContext context, Paginator<ReadingGoal> paginator) {
    final scrollController = context.read<ScrollController>();

    final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 1,
      childAspectRatio: 9/3,
      mainAxisSpacing: 12
    );

    SliverChildBuilderDelegate childrenDelegateProvider(
      List<ReadingGoal> readingGoals,
      int totalReadingGoals
    ) => SliverChildBuilderDelegate(
      (context, index) => _ClubReadingCard(readingGoal: readingGoals[index]),
      childCount: totalReadingGoals
    );

    return SliverPadding(
      padding: EdgeInsets.only(
        top: 12,
        left: 12,
        right: 12,
        bottom: 36
      ),
      sliver: InfiniteGridWidget.sliver(
        paginator: paginator,
        controller: scrollController,
        gridDelegate: gridDelegate,
        childrenDelegateProvider: childrenDelegateProvider
      ),
    );
  }

  Widget onLoading(BuildContext context) {
    return SliverFillRemaining(
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
        child: Text('Erro ao carregar leituras do clube'),
      ),
    );
  }

}

class _ClubReadingCard extends StatelessWidget {

  final ReadingGoal readingGoal;

  const _ClubReadingCard({
    required this.readingGoal
  });

  @override
  Widget build(BuildContext context) {
    final bookRepository = context.read<BookApiRepository>();

    return AsyncBuilder(
      future: bookRepository.getBookById(readingGoal.bookId),
      onRetrieved: (book) => _buildCard(context, book),
      onLoading: () => _buildCard(context, null, isLoading: true),
      onError: (_, _) => _buildCard(context, null),
    );
  }

  Widget _buildCard(
    BuildContext context,
    BookItem? book, {
    bool isLoading = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final border = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    Widget placeholder() => Container(
          height: 90,
          width: 64,
          color: colorScheme.surfaceContainerHighest,
          child: Icon(
            isLoading ? Icons.hourglass_empty : Icons.menu_book_rounded,
            color: colorScheme.primary,
          ),
        );

    final cover = ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SafeNetworkImage(
        url: book?.thumbnail,
        height: 90,
        width: 64,
        fit: BoxFit.cover,
        placeholder: placeholder(),
      ),
    );

    final dateFormat = DateFormat('dd/MM/yyyy');
    final period =
        '${dateFormat.format(readingGoal.startDate)} - '
        '${dateFormat.format(readingGoal.endDate)}';

    final details = Expanded(
      child: Column(
        spacing: 4,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            book?.title ?? (isLoading ? 'Carregando...' : 'Livro indisponível'),
            style: textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (book?.authors != null)
            Row(
              spacing: 4,
              children: [
                Icon(Icons.person, size: 16),
                Expanded(
                  child: Text(
                    book!.authors!,
                    style: textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          Row(
            spacing: 4,
            children: [
              Icon(Icons.calendar_today, size: 14),
              Text(period, style: textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );

    void onTap() {
      final bookId = book?.id ?? readingGoal.bookId;
      context.push(Routes.individualBook(bookId: bookId));
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: border,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            spacing: 12,
            children: [
              cover,
              details,
            ],
          ),
        ),
      ),
    );
  }

}
