import 'package:flutter/material.dart';

/// An inline error banner shown on form pages when a submission fails.
class FormErrorBannerWidget extends StatelessWidget {
  final String message;

  const FormErrorBannerWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.40)),
      ),
      child: Row(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: colorScheme.error),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}