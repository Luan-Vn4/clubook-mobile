import 'package:flutter/material.dart';

class ReviewFormResult {
  final int rating;
  final String review;

  const ReviewFormResult({required this.rating, required this.review});
}

/// A dialog that collects a star rating (1-5) and an optional written review.
class ReviewFormDialog extends StatefulWidget {
  final String title;

  const ReviewFormDialog({super.key, required this.title});

  static Future<ReviewFormResult?> show(
    BuildContext context, {
    required String title,
  }) {
    return showDialog<ReviewFormResult>(
      context: context,
      builder: (_) => ReviewFormDialog(title: title),
    );
  }

  @override
  State<ReviewFormDialog> createState() => _ReviewFormDialogState();
}

class _ReviewFormDialogState extends State<ReviewFormDialog> {
  int _rating = 0;
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sua nota', style: textTheme.bodyMedium),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => setState(() => _rating = i),
                  iconSize: 32,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36),
                  icon: Icon(
                    i <= _rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: colorScheme.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reviewController,
            maxLines: 4,
            maxLength: 500,
            decoration: const InputDecoration(
              labelText: 'Resenha (opcional)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _rating == 0
              ? null
              : () => Navigator.of(context).pop(
                  ReviewFormResult(
                    rating: _rating,
                    review: _reviewController.text.trim(),
                  ),
                ),
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}