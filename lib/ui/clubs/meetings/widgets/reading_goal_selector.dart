import 'package:booklub/config/theme/theme_config.dart';
import 'package:booklub/domain/reading_goals/entities/reading_goal_with_book.dart';
import 'package:booklub/ui/core/widgets/buttons/purple_rounded_button.dart';
import 'package:booklub/ui/core/widgets/top_inner_shadow.dart/top_inner_shadow.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Load-state of the reading-goals list shown by [ReadingGoalSelector].
///
/// Drives the top-level branching of the widget's `build`:
/// - [idle]    : nothing has been requested yet (renders nothing).
/// - [loading] : the list is being fetched (centered spinner).
/// - [loaded]  : at least one reading goal is available (dropdown).
/// - [empty]   : the club has no reading goals (empty-state + CTA).
/// - [error]   : the fetch failed (inline error text).
enum ReadingGoalsLoadState { idle, loading, loaded, empty, error }

/// Selector for a club's reading-goals on the Meeting creation screen.
///
/// Renders a custom dropdown field with an overlay list when goals are
/// available, or a redirect empty-state that prompts the user to create a
/// reading goal before creating a meeting. The widget is pure: navigation is
/// delegated to the host page via [onCreateReadingGoalTap].
class ReadingGoalSelector extends StatefulWidget {
  /// Reading goals available for selection. Ignored unless [loadState] is
  /// [ReadingGoalsLoadState.loaded].
  final List<ReadingGoalWithBook> goals;

  /// Currently selected reading goal, or `null` if none is selected.
  final ReadingGoalWithBook? selected;

  /// Notified when the user picks a goal from the dropdown. Nullable so the
  /// selector can be reused in read-only previews without wiring a handler.
  final ValueChanged<ReadingGoalWithBook>? onSelect;

  /// Which branch of the widget to render.
  final ReadingGoalsLoadState loadState;

  /// Invoked by the empty-state CTA. The host page navigates to reading-goal
  /// creation and re-fetches the list on return.
  final VoidCallback? onCreateReadingGoalTap;

  const ReadingGoalSelector({
    super.key,
    required this.goals,
    required this.selected,
    required this.onSelect,
    required this.loadState,
    required this.onCreateReadingGoalTap,
  });

  @override
  State<ReadingGoalSelector> createState() => _ReadingGoalSelectorState();
}

class _ReadingGoalSelectorState extends State<ReadingGoalSelector> {
  final GlobalKey _fieldKey = GlobalKey();
  final LayerLink _fieldLink = LayerLink();

  OverlayEntry? _overlayEntry;
  double _fieldWidth = 0;
  double _maxHeight = 0;
  bool _showAbove = false;
  bool _isOpen = false;

  @override
  void didUpdateWidget(ReadingGoalSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isOpen) {
      _overlayEntry?.markNeedsBuild();
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  void _toggleDropdown() {
    if (_isOpen) {
      _hideDropdown();
    } else {
      _showDropdown();
    }
  }

  void _showDropdown() {
    _fieldWidth = _fieldKey.currentContext?.size?.width ??
        (MediaQuery.sizeOf(context).width - 48);

    final renderBox =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    final screenHeight = MediaQuery.sizeOf(context).height;

    if (renderBox != null) {
      final fieldTop = renderBox.localToGlobal(Offset.zero).dy;
      final fieldBottom = fieldTop + renderBox.size.height;
      final spaceBelow = screenHeight - fieldBottom;
      final spaceAbove = fieldTop;

      _showAbove = spaceBelow < 200 && spaceAbove > spaceBelow;
      _maxHeight = (_showAbove ? spaceAbove : spaceBelow) - 8;
    } else {
      _showAbove = false;
      _maxHeight = screenHeight * 0.4;
    }

    _overlayEntry = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _hideDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  Widget _buildOverlay(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _hideDropdown,
          ),
        ),
        CompositedTransformFollower(
          link: _fieldLink,
          targetAnchor: _showAbove ? Alignment.topLeft : Alignment.bottomLeft,
          followerAnchor:
              _showAbove ? Alignment.bottomLeft : Alignment.topLeft,
          offset: Offset(0, _showAbove ? -4 : 4),
          child: SizedBox(
            width: _fieldWidth,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              color: colorScheme.surface,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: _maxHeight),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final goal in widget.goals)
                        ListTile(
                          title: Text(
                            goal.book.title,
                            style:
                                Theme.of(context).textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${_formatDate(goal.startDate)}'
                            ' – ${_formatDate(goal.endDate)}',
                            style: TextStyle(
                              color: colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                          onTap: () {
                            widget.onSelect?.call(goal);
                            _hideDropdown();
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.loadState) {
      case ReadingGoalsLoadState.idle:
        return const SizedBox.shrink();
      case ReadingGoalsLoadState.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        );
      case ReadingGoalsLoadState.empty:
        return _buildEmptyState();
      case ReadingGoalsLoadState.error:
        return _buildErrorState(context);
      case ReadingGoalsLoadState.loaded:
        return _buildField(context);
    }
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 16,
      children: [
        const Text(
          'Você deve criar uma meta de leitura antes de criar encontros',
          textAlign: TextAlign.center,
        ),
        if (widget.onCreateReadingGoalTap != null)
          PurpleRoundedButton(
            'Criar Meta de Leitura',
            widget.onCreateReadingGoalTap!,
          ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          'Erro ao carregar metas de leitura',
          style: TextStyle(color: colorScheme.error),
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context) {
    return Stack(
      children: [
        CompositedTransformTarget(
          link: _fieldLink,
          child: GestureDetector(
            onTap: _toggleDropdown,
            child: _buildInputDecorator(context),
          ),
        ),
        const TopInnerShadow(),
      ],
    );
  }

  Widget _buildInputDecorator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    const borderRadius = BorderRadius.all(Radius.circular(8));

    final enabledBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
      borderRadius: borderRadius,
    );

    final focusedBorder = OutlineInputBorder(
      borderSide: BorderSide(color: colorScheme.primary),
      borderRadius: borderRadius,
    );

    return InputDecorator(
      key: _fieldKey,
      isEmpty: widget.selected == null,
      isFocused: _isOpen,
      decoration: InputDecoration(
        labelText: 'Meta de Leitura',
        labelStyle: TextStyle(color: colorScheme.superLightBlack),
        floatingLabelStyle: TextStyle(color: colorScheme.onSurface),
        filled: true,
        fillColor: colorScheme.surfaceContainerHigh,
        enabledBorder: enabledBorder,
        focusedBorder: focusedBorder,
        suffixIcon: Icon(
          _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          color: colorScheme.secondary,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        widget.selected?.book.title ?? '',
        style: Theme.of(context).textTheme.bodyMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
}
