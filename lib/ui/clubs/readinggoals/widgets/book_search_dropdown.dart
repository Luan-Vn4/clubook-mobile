import 'package:booklub/domain/entities/books/book_item.dart';
import 'package:flutter/material.dart';

/// Dropdown overlay that presents book-search results, loading and error
/// states for the reading-goal creation screen.
///
/// Renders nothing when there are no results and the widget is neither in the
/// loading nor in the error state.
class BookSearchDropdown extends StatelessWidget {
  final List<BookItem> results;

  final bool isLoading;

  final bool hasError;

  final ValueChanged<BookItem> onSelected;

  const BookSearchDropdown({
    super.key,
    required this.results,
    required this.isLoading,
    required this.hasError,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return _buildError(context);
    }
    if (isLoading) {
      return _buildLoading(context);
    }
    if (results.isEmpty) {
      return const SizedBox.shrink();
    }
    return _buildResults(context);
  }

  Widget _buildError(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Não foi possível buscar por livros',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Card(
      elevation: 4,
      child: SizedBox(
        height: 56,
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final visibleResults = results.take(5).toList(growable: false);

    return Card(
      elevation: 4,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final book in visibleResults)
            ListTile(
              title: Text(book.title),
              subtitle:
                  book.authors == null ? null : Text(book.authors!),
              onTap: () => onSelected(book),
            ),
        ],
      ),
    );
  }
}
