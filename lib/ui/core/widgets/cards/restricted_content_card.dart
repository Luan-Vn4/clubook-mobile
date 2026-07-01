import 'package:flutter/material.dart';

/// Shown in place of club content (activities, readings, meetings) that the
/// current user can't see because the club is private and they aren't a member.
class RestrictedContentCard extends StatelessWidget {
  final String message;

  const RestrictedContentCard({
    super.key,
    this.message = 'Conteúdo restrito aos membros deste clube privado.',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          spacing: 12,
          children: [
            Icon(Icons.lock_rounded, color: colorScheme.onSurfaceVariant),
            Expanded(
              child: Text(
                message,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
