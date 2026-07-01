import 'package:booklub/domain/entities/books/book_item.dart';
import 'package:booklub/ui/clubs/readinggoals/widgets/book_cover_preview.dart';
import 'package:booklub/ui/clubs/readinggoals/widgets/book_search_dropdown.dart';
import 'package:booklub/ui/core/view_models/create_reading_goal_view_model.dart';
import 'package:booklub/ui/core/widgets/buttons/purple_rounded_button.dart';
import 'package:booklub/ui/core/widgets/input_fields/named_date_field_widget.dart';
import 'package:booklub/ui/core/widgets/input_fields/named_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CreateReadingGoalPage extends StatefulWidget {
  final String clubId;

  const CreateReadingGoalPage({super.key, required this.clubId});

  @override
  State<CreateReadingGoalPage> createState() => _CreateReadingGoalPageState();
}

class _CreateReadingGoalPageState extends State<CreateReadingGoalPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey _bookFieldKey = GlobalKey();
  final LayerLink _bookFieldLink = LayerLink();

  OverlayEntry? _dropdownOverlay;
  double _fieldWidth = 0;
  CreateReadingGoalViewModel? _vm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _vm = context.read<CreateReadingGoalViewModel>();
      _vm!.addListener(_onSearchStateChanged);
      _onSearchStateChanged();
    });
  }

  @override
  void dispose() {
    _vm?.removeListener(_onSearchStateChanged);
    _hideDropdown();
    super.dispose();
  }

  void _onSearchStateChanged() {
    if (!mounted) return;
    final vm = _vm;
    if (vm == null) return;

    _fieldWidth = _bookFieldKey.currentContext?.size?.width ??
        (MediaQuery.sizeOf(context).width - 48);

    final isVisible = vm.searchState == BookSearchState.loading ||
        vm.searchState == BookSearchState.results ||
        vm.searchState == BookSearchState.error;

    if (isVisible) {
      if (_dropdownOverlay == null) {
        _showDropdown(vm);
      } else {
        _dropdownOverlay?.markNeedsBuild();
      }
    } else {
      _hideDropdown();
    }
  }

  void _showDropdown(CreateReadingGoalViewModel vm) {
    _dropdownOverlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _hideDropdown,
              ),
            ),
            CompositedTransformFollower(
              link: _bookFieldLink,
              targetAnchor: Alignment.bottomLeft,
              followerAnchor: Alignment.topLeft,
              offset: const Offset(0, 4),
              child: SizedBox(
                width: _fieldWidth,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surface,
                  child: BookSearchDropdown(
                    results: vm.searchResults,
                    isLoading: vm.searchState == BookSearchState.loading,
                    hasError: vm.searchState == BookSearchState.error,
                    onSelected: (BookItem book) => vm.selectBook(book),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_dropdownOverlay!);
  }

  void _hideDropdown() {
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateReadingGoalViewModel>();

    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          spacing: 24,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Builder(builder: (context) => _buildCover(context, viewModel)),
            Builder(builder: (_) => _buildForm(context, viewModel)),
            Builder(builder: (_) => _buildButton(context, viewModel)),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(
    BuildContext context,
    CreateReadingGoalViewModel vm,
  ) {
    return BookCoverPreview(book: vm.selectedBookItem);
  }

  Widget _buildForm(BuildContext context, CreateReadingGoalViewModel vm) {
    return Form(
      key: _formKey,
      child: Column(
        spacing: 24,
        children: [
          CompositedTransformTarget(
            link: _bookFieldLink,
            child: NamedTextFieldWidget(
              key: _bookFieldKey,
              label: "Nome do livro",
              inputWrapper: vm.bookTitleInput,
              onChanged: vm.onBookTitleChanged,
            ),
          ),
          NamedDateFieldWidget(
            label: "Data Início",
            inputWrapper: vm.startDateTextInput,
            onDateSelected: vm.setStartDate,
          ),
          NamedDateFieldWidget(
            label: "Data Final",
            inputWrapper: vm.endDateTextInput,
            onDateSelected: vm.setEndDate,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, CreateReadingGoalViewModel vm) {
    return PurpleRoundedButton("Criar", () async {
      if (_formKey.currentState?.validate() ?? false) {
        final success = await vm.createReadingGoal();
        if (context.mounted && success) context.pop();
      }
    });
  }
}
