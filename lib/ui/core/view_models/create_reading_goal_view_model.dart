import 'dart:async';

import 'package:booklub/domain/entities/books/book_item.dart';
import 'package:booklub/domain/reading_goals/entities/reading_goal_creation_dto.dart';
import 'package:booklub/infra/auth/auth_repository.dart';
import 'package:booklub/infra/books/book_api_repository.dart';
import 'package:booklub/infra/reading_goals/reading_goals_repository.dart';
import 'package:booklub/ui/core/view_models/async_change_notifier.dart';
import 'package:booklub/utils/validation/input_validators.dart';
import 'package:booklub/utils/validation/input_wrapper.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:booklub/utils/logger/app_logger.dart';

enum BookSearchState { idle, loading, results, error, empty }

class CreateReadingGoalViewModel extends AsyncChangeNotifier<void> {
  final Logger log = AppLogger.create();
  final AuthRepository authRepository;
  final ReadingGoalsRepository readingGoalsRepository;
  final BookApiRepository bookApiRepository;
  final InputValidators inputValidators = InputValidators();
  final String clubId;

  late final InputWrapper bookTitleInput;
  late final InputWrapper startDateTextInput;
  late final InputWrapper endDateTextInput;

  late final ValueNotifier<DateTime?> startDateInput;
  late final ValueNotifier<DateTime?> endDateInput;

  bool created = false;
  BookItem? selectedBookItem;

  List<BookItem> searchResults = [];

  BookSearchState searchState = BookSearchState.idle;

  Timer? _debounceTimer;

  CreateReadingGoalViewModel({
    required this.authRepository,
    required this.readingGoalsRepository,
    required this.bookApiRepository,
    required this.clubId,
  }) {
    bookTitleInput = InputWrapper(
      controller: TextEditingController(),
      validator: inputValidators.validateBasicTextField,
    );
    bookTitleInput.addListener(notifyListeners);

    startDateTextInput = InputWrapper(
      controller: TextEditingController(),
      validator: inputValidators.validateBasicTextField,
    )..addListener(notifyListeners);

    endDateTextInput = InputWrapper(
      controller: TextEditingController(),
      validator: inputValidators.validateBasicTextField,
    )..addListener(notifyListeners);

    startDateInput = ValueNotifier(null)..addListener(notifyListeners);
    endDateInput = ValueNotifier(null)..addListener(notifyListeners);
  }

  void setStartDate(DateTime? date) {
    if (date != null) {
      startDateInput.value = date;
      startDateTextInput.text = DateFormat('dd/MM/yyyy').format(date);
    }
  }

  void setEndDate(DateTime? date) {
    if (date != null) {
      endDateInput.value = date;
      endDateTextInput.text = DateFormat('dd/MM/yyyy').format(date);
    }
  }

  @override
  void get payload {
    return;
  }

  bool get isValid {
    return bookTitleInput.isValid &&
        selectedBookItem != null &&
        startDateInput.value != null &&
        endDateInput.value != null &&
        startDateInput.value!.isBefore(endDateInput.value!);
  }

  void onBookTitleChanged(String text) {
    _debounceTimer?.cancel();
    final trimmed = text.trim();

    if (trimmed.length < 3) {
      searchState = BookSearchState.idle;
      searchResults = [];
      notifyListeners();
      return;
    }

    _debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () => _search(trimmed),
    );
  }

  Future<void> _search(String query) async {
    searchState = BookSearchState.loading;
    notifyListeners();

    try {
      final paginator = await bookApiRepository.searchBooks(
        intitle: query,
        size: 5,
      );
      final page = await paginator[0];
      searchResults = page.content;
      searchState = searchResults.isEmpty
          ? BookSearchState.empty
          : BookSearchState.results;
    } catch (e, stackTrace) {
      searchState = BookSearchState.error;
      log.e(
        'Erro ao buscar livro por título',
        error: e,
        stackTrace: stackTrace,
      );
    } finally {
      notifyListeners();
    }
  }

  void selectBook(BookItem book) {
    selectedBookItem = book;
    bookTitleInput.text = book.title;
    searchState = BookSearchState.idle;
    searchResults = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    bookTitleInput.controller.dispose();
    startDateTextInput.controller.dispose();
    endDateTextInput.controller.dispose();
    startDateInput.dispose();
    endDateInput.dispose();
    super.dispose();
  }

  Future<bool> createReadingGoal() async {
    final authData = await authRepository.getAuthData();
    if (authData == null) throw Exception('O usuário não está autenticado');

    if (!isValid) {
      log.d('dados invalidos para criar reading goal');
      return false;
    }

    super.isLoading = true;
    notifyListeners();

    try {
      final dto = CreateReadingGoalDto(
        bookId: selectedBookItem!.id ?? (throw Exception('Livro sem ID')),
        startDate: startDateInput.value!.toIso8601String().substring(0, 10),
        endDate: endDateInput.value!.toIso8601String().substring(0, 10),
      );

      await readingGoalsRepository.createReadingGoal(dto, clubId);
      created = true;
      return true;
    } catch (e, stackTrace) {
      log.e('Erro ao criar reading goal', error: e, stackTrace: stackTrace);
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
