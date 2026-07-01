import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final bool centerContent;

  const EmptyStateWidget({
    super.key,
    required this.message,
    this.icon,
    this.actionText,
    this.onActionPressed,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 48,
              color: colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          message,
          textAlign: centerContent ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        if (actionText != null && onActionPressed != null) ...[
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onActionPressed,
            icon: const Icon(Icons.search),
            label: Text(actionText!),
          ),
        ],
      ],
    );

    if (centerContent) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: content),
      );
    }

    return content;
  }
}
