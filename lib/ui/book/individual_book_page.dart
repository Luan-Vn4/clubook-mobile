// ignore_for_file: avoid_print

import 'package:booklub/domain/entities/books/book_rating.dart';
import 'package:booklub/domain/entities/users/user.dart';
import 'package:booklub/ui/book/view_models/book_profile_view_model.dart';
import 'package:booklub/ui/core/view_models/user_view_model.dart';
import 'package:booklub/ui/core/widgets/safe_network_image.dart';
import 'package:booklub/utils/async_builder.dart';
import 'package:flutter/material.dart';
import 'package:booklub/ui/core/layouts/scroll_base_layout.dart';
import 'package:provider/provider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:booklub/ui/book/widgets/star_rating_widget.dart';
import 'package:booklub/ui/book/widgets/stats_card_widget.dart';

class IndividualBookPage extends StatelessWidget {
  const IndividualBookPage({super.key, required this.bookId});

  final String bookId; // o volumeId do livro

  @override
  Widget build(BuildContext context) {
    print('chegou no individual book page');
    final viewModel = context.read<BookProfileViewModel>();

    print('chegou depois do read');

    return AsyncBuilder.fromAsyncChangeNotifier(
      asyncChangeNotifier: viewModel,
      onRetrieved: (book) {
        print('chegou ate aqui');
        return Builder(builder: _buildPage);
      },
      onLoading: () => Builder(builder: _buildLoadingPage),
      onError: (_, __) => Builder(builder: _buildErrorPage),
    );
  }

  Widget _buildLoadingPage(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [CircularProgressIndicator()],
      ),
    );
  }

  Widget _buildErrorPage(BuildContext context) {
  final viewModel = context.read<BookProfileViewModel>();
  final textTheme = Theme.of(context).textTheme;
  final colorScheme = Theme.of(context).colorScheme;

  return ScrollBaseLayout(
    sliver: SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Livro com ID "${viewModel.book?.id ?? bookId}" não encontrado',
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}


  Widget _buildPage(BuildContext context) {
    final book = context.watch<BookProfileViewModel>();
    print('chegou no build page com book de id: ${book.book?.id}');
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return MultiSliver(
      children: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCoverAndTitleSection(textTheme, colorScheme, book),
                _buildClubStatsSection(context, colorScheme),
                Column(
                  spacing: 24,
                  children: [
                    _buildRatingSection(context),
                    _buildReviewSection(context, textTheme),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverAndTitleSection(
    TextTheme textTheme,
    ColorScheme colorScheme,
    book,
  ) {
    final bookData = book.book;
    print('chegou no buildCoverAndTitleSection com bookData: $bookData');
    final year =
        bookData?.datePublished != null && bookData?.datePublished!.isNotEmpty
            ? bookData!.datePublished!.split('-').first
            : null;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 229,
            width: 153,
            child: bookData.thumbnail != null
                ? SafeNetworkImage(
                    url: bookData.thumbnail!,
                    width: 153,
                    height: 229,
                    fit: BoxFit.cover,
                    placeholder: Image.asset(
                      'assets/images/misery_capa.jpg',
                      fit: BoxFit.cover,
                      width: 153,
                      height: 229,
                    ),
                  )
                : Image.asset(
                    'assets/images/misery_capa.jpg',
                    fit: BoxFit.cover,
                    width: 153,
                    height: 229,
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            bookData.title,
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontFamily: 'Navicula',
              fontSize: 42,
            ),
            textAlign: TextAlign.center,
          ),
          if (bookData.authors != null)
            Text(
              bookData.authors!,
              style: textTheme.titleSmall?.copyWith(
                color: colorScheme.secondary,
                fontFamily: 'Navicula',
                fontSize: 28,
              ),
              textAlign: TextAlign.center,
            ),
          if (year != null)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                Chip(
                  label: Text(
                    year,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  backgroundColor: Colors.grey[700],
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildClubStatsSection(BuildContext context, ColorScheme colorScheme) {
    final stats = context.watch<BookProfileViewModel>().clubStats;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StatsCard(
          number: stats != null ? stats.alreadyRead.toString() : '—',
          label: 'clubes já leram',
          colorScheme: colorScheme,
        ),
        const SizedBox(width: 20),
        StatsCard(
          number: stats != null ? stats.currentlyReading.toString() : '—',
          label: 'clubes estão lendo',
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    final viewModel = context.watch<BookProfileViewModel>();
    final textTheme = Theme.of(context).textTheme;
    final average = viewModel.averageRating;

    if (average == null) {
      return Center(
        child: Text('Ainda sem avaliações', style: textTheme.bodyMedium),
      );
    }

    return Center(child: StarRating(rating: average));
  }

  Widget _buildReviewSection(BuildContext context, TextTheme textTheme) {
    final viewModel = context.watch<BookProfileViewModel>();
    final ratings = viewModel.ratings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Resenhas",
          style: textTheme.titleMedium?.copyWith(
            fontFamily: 'Navicula',
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 12),
        if (ratings.isEmpty)
          Text('Nenhuma resenha ainda.', style: textTheme.bodyMedium)
        else
          ...ratings.map(
            (rating) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RealReviewCard(rating: rating),
            ),
          ),
      ],
    );
  }
}

class _RealReviewCard extends StatelessWidget {
  final BookRating rating;

  const _RealReviewCard({required this.rating});

  @override
  Widget build(BuildContext context) {
    return AsyncBuilder(
      future: context.read<UserViewModel>().getUser(rating.userId),
      onLoading: () => _buildCard(context, null),
      onError: (_, _) => _buildCard(context, null),
      onRetrieved: (user) => _buildCard(context, user),
    );
  }

  Widget _buildCard(BuildContext context, User? user) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final hasAvatar = user?.imageUrl != null && user!.imageUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.surfaceContainerHighest,
                backgroundImage: hasAvatar ? safeNetworkImageProvider(user.imageUrl!) : null,
                child: hasAvatar
                    ? null
                    : Icon(Icons.person, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'Membro do clube',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (user != null)
                      Text(
                        '@${user.username}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StarRating(
            rating: rating.rating.toDouble(),
            iconSize: 20,
            showNumber: false,
          ),
          if (rating.review != null && rating.review!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(rating.review!, style: textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}