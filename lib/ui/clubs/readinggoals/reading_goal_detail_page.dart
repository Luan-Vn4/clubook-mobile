import 'package:booklub/domain/entities/books/book_item.dart';
import 'package:booklub/domain/reading_goals/entities/reading_goal.dart';
import 'package:booklub/infra/auth/auth_repository.dart';
import 'package:booklub/infra/books/book_api_repository.dart';
import 'package:booklub/infra/clubs/club_repository.dart';
import 'package:booklub/infra/reading_goals/reading_goals_repository.dart';
import 'package:booklub/ui/book/widgets/review_form_dialog.dart';
import 'package:booklub/ui/core/widgets/safe_network_image.dart';
import 'package:booklub/utils/async_builder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

typedef _ReadingGoalData = ({
  ReadingGoal goal,
  BookItem? book,
  String? ownerId,
  String currentUserId,
});

class ReadingGoalDetailPage extends StatefulWidget {
  final String readingGoalId;

  const ReadingGoalDetailPage({super.key, required this.readingGoalId});

  @override
  State<ReadingGoalDetailPage> createState() => _ReadingGoalDetailPageState();
}

class _ReadingGoalDetailPageState extends State<ReadingGoalDetailPage> {
  late Future<_ReadingGoalData> _dataFuture;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<_ReadingGoalData> _loadData() async {
    final readingGoalsRepository = context.read<ReadingGoalsRepository>();
    final bookRepository = context.read<BookApiRepository>();
    final clubRepository = context.read<ClubRepository>();
    final authRepository = context.read<AuthRepository>();

    final goal = await readingGoalsRepository.findById(widget.readingGoalId);
    final authData = await authRepository.getAuthData();

    BookItem? book;
    try {
      book = await bookRepository.getBookById(goal.bookId);
    } catch (_) {
      book = null;
    }

    String? ownerId;
    try {
      final club = await clubRepository.findClubById(goal.clubId);
      ownerId = club.ownerId;
    } catch (_) {
      ownerId = null;
    }

    return (
      goal: goal,
      book: book,
      ownerId: ownerId,
      currentUserId: authData?.user.id ?? '',
    );
  }

  void _reload() {
    setState(() {
      _dataFuture = _loadData();
    });
  }

  bool _isPeriodOver(ReadingGoal goal) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(
      goal.endDate.year,
      goal.endDate.month,
      goal.endDate.day,
    );
    return today.isAfter(end);
  }

  Future<void> _onFinish(ReadingGoal goal) async {
    final result = await ReviewFormDialog.show(
      context,
      title: 'Finalizar e avaliar',
    );
    if (result == null || !mounted) return;

    setState(() => _submitting = true);
    try {
      await context.read<ReadingGoalsRepository>().finishReadingGoal(
        goal.id,
        rating: result.rating,
        review: result.review.isEmpty ? null : result.review,
      );
      if (mounted) {
        _showSnack('Leitura finalizada e avaliada!');
        _reload();
      }
    } catch (e) {
      if (mounted) _showSnack(_messageFor(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _onReview(ReadingGoal goal) async {
    final result = await ReviewFormDialog.show(context, title: 'Avaliar livro');
    if (result == null || !mounted) return;

    setState(() => _submitting = true);
    try {
      await context.read<ReadingGoalsRepository>().reviewReadingGoal(
        goal.id,
        rating: result.rating,
        review: result.review.isEmpty ? null : result.review,
      );
      if (mounted) _showSnack('Avaliação enviada!');
    } catch (e) {
      if (mounted) _showSnack(_messageFor(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _messageFor(Object e) {
    if (e is ReadingGoalException) return e.message;
    return 'Não foi possível concluir a ação. Tente novamente.';
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AsyncBuilder(
          future: _dataFuture,
          onLoading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          onError: (_, _) => const Center(
            child: Text('Não foi possível carregar esta leitura.'),
          ),
          onRetrieved: (data) => _buildContent(context, data),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, _ReadingGoalData data) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final goal = data.goal;
    final book = data.book;
    final isOwner = data.ownerId != null && data.ownerId == data.currentUserId;
    final periodOver = _isPeriodOver(goal);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 200,
          width: 134,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: book?.thumbnail != null
                ? SafeNetworkImage(
                    url: book!.thumbnail!,
                    width: 134,
                    height: 200,
                    fit: BoxFit.cover,
                    placeholder: _coverPlaceholder(colorScheme),
                  )
                : _coverPlaceholder(colorScheme),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          book?.title ?? 'Livro',
          style: textTheme.titleLarge?.copyWith(color: colorScheme.primary),
          textAlign: TextAlign.center,
        ),
        if (book?.authors != null) ...[
          const SizedBox(height: 4),
          Text(book!.authors!, style: textTheme.bodyMedium),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            Icon(Icons.calendar_month_rounded, size: 18),
            Text(
              '${dateFormat.format(goal.startDate)} → '
              '${dateFormat.format(goal.endDate)}',
              style: textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatusChip(context, goal, periodOver),
        const SizedBox(height: 24),
        _buildActionSection(context, goal, isOwner, periodOver),
      ],
    );
  }

  Widget _buildStatusChip(
    BuildContext context,
    ReadingGoal goal,
    bool periodOver,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (IconData icon, String label, Color color) = goal.finished
        ? (Icons.check_circle_rounded, 'Leitura finalizada', colorScheme.primary)
        : periodOver
        ? (Icons.timelapse_rounded, 'Período encerrado', colorScheme.secondary)
        : (Icons.menu_book_rounded, 'Leitura em andamento', colorScheme.secondary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Icon(icon, size: 16, color: color),
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection(
    BuildContext context,
    ReadingGoal goal,
    bool isOwner,
    bool periodOver,
  ) {
    if (_submitting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (isOwner) {
      if (goal.finished) {
        return _infoCard(
          context,
          Icons.check_circle_rounded,
          'Você finalizou esta leitura. Obrigado por avaliar!',
        );
      }
      return FilledButton.icon(
        onPressed: () => _onFinish(goal),
        icon: const Icon(Icons.task_alt_rounded),
        label: const Text('Finalizar leitura e avaliar'),
      );
    }

    // Members
    if (periodOver) {
      return FilledButton.icon(
        onPressed: () => _onReview(goal),
        icon: const Icon(Icons.rate_review_rounded),
        label: const Text('Avaliar livro'),
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy');
    return _infoCard(
      context,
      Icons.lock_clock_rounded,
      'Você poderá avaliar este livro após o término da leitura, '
          'em ${dateFormat.format(goal.endDate)}.',
    );
  }

  Widget _infoCard(BuildContext context, IconData icon, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        spacing: 12,
        children: [
          Icon(icon, color: colorScheme.primary),
          Expanded(child: Text(message, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _coverPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Icon(Icons.menu_book_rounded, color: colorScheme.primary, size: 48),
    );
  }
}