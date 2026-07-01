import 'package:booklub/domain/entities/books/book_item.dart';
import 'package:flutter/material.dart';

/// Preview that displays the cover of the currently selected [BookItem].
///
/// Falls back to the application logo asset when no book is selected, when the
/// book has no thumbnail URL, or when the network image fails to load.
class BookCoverPreview extends StatelessWidget {
  final BookItem? book;

  const BookCoverPreview({super.key, this.book});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.20;
    final thumbnail = book?.thumbnail;

    if (thumbnail == null || thumbnail.isEmpty) {
      return Image.asset(
        'assets/images/booklub_logo_icon.png',
        height: height,
      );
    }

    return Image.network(
      thumbnail,
      height: height,
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) => Image.asset(
        'assets/images/booklub_logo_icon.png',
        height: height,
      ),
    );
  }
}
