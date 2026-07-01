import 'package:booklub/domain/geocoding/models/geocoding_result.dart';
import 'package:flutter/material.dart';

/// Dropdown overlay content that presents geocoding search results, loading
/// and error states for the meeting creation location picker.
///
/// The surrounding [Material] in the overlay builder already provides the
/// elevation, background colour and border radius; this widget only supplies
/// the inner content (ListTiles, spinner, error message).
class LocationSearchDropdown extends StatelessWidget {
  final List<GeocodingResult> results;

  final bool isLoading;

  final bool hasError;

  final ValueChanged<GeocodingResult> onSelected;

  const LocationSearchDropdown({
    super.key,
    required this.results,
    required this.isLoading,
    required this.hasError,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (hasError) return _buildError(context);
    if (isLoading) return _buildLoading(context);
    if (results.isEmpty) return const SizedBox.shrink();
    return _buildResults(context);
  }

  Widget _buildError(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Não foi possível buscar o endereço',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return const SizedBox(
      height: 56,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildResults(BuildContext context) {
    final visibleResults = results.take(5).toList(growable: false);
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final result in visibleResults)
          ListTile(
            title: Text(
              result.address,
              style: theme.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '${result.latitude.toStringAsFixed(4)}, '
              '${result.longitude.toStringAsFixed(4)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            onTap: () => onSelected(result),
          ),
      ],
    );
  }
}
