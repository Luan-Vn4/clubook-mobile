import 'package:booklub/domain/entities/books/book_item.dart';
import 'package:booklub/infra/auth/auth_repository.dart';
import 'package:booklub/infra/books/book_api_repository.dart';
import 'package:booklub/infra/reading_goals/reading_goals_repository.dart';
import 'package:booklub/ui/core/view_models/create_reading_goal_view_model.dart';
import 'package:booklub/utils/pagination/page.dart';
import 'package:booklub/utils/pagination/paginator.dart';
import 'package:flutter_test/flutter_test.dart';

class _AuthRepoStub extends AuthRepository {
  _AuthRepoStub() : super(apiUrl: '');
}

class _ReadingGoalsRepoStub extends ReadingGoalsRepository {
  _ReadingGoalsRepoStub()
    : super(authRepository: _AuthRepoStub(), apiUrl: '');
}

class _FakeBookApiRepository extends BookApiRepository {
  _FakeBookApiRepository() : super(apiUrl: '', authRepository: _AuthRepoStub());

  List<BookItem> books = const <BookItem>[];

  bool shouldThrow = false;

  int searchCallCount = 0;

  String? lastQuery;

  @override
  Future<Paginator<BookItem>> searchBooks({
    String? id,
    required String intitle,
    String? inauthor,
    String? inpublisher,
    String? subject,
    String? isbn,
    String? publishedDate,
    int page = 0,
    int size = 10,
  }) async {
    searchCallCount += 1;
    lastQuery = intitle;
    if (shouldThrow) {
      throw Exception('boom');
    }
    return Paginator.create<BookItem>(
      size,
      (int innerPage, int innerPageSize) async => Page<BookItem>(
        content: List<BookItem>.from(books),
        pageInfo: PageInfo(
          size: innerPageSize,
          number: innerPage,
          totalElements: books.length,
          totalPages: 1,
        ),
      ),
    );
  }
}

void main() {
  late _FakeBookApiRepository bookApiRepository;
  late CreateReadingGoalViewModel vm;

  setUp(() {
    bookApiRepository = _FakeBookApiRepository();
    vm = CreateReadingGoalViewModel(
      authRepository: _AuthRepoStub(),
      readingGoalsRepository: _ReadingGoalsRepoStub(),
      bookApiRepository: bookApiRepository,
      clubId: 'club-1',
    );
  });

  tearDown(() => vm.dispose());

  test(
    'onBookTitleChanged com menos de 3 caracteres não dispara busca e mantém idle',
    () {
      vm.onBookTitleChanged('ab');

      expect(bookApiRepository.searchCallCount, 0);
      expect(vm.searchState, BookSearchState.idle);
      expect(vm.searchResults, isEmpty);
    },
  );

  test(
    'onBookTitleChanged com mais de 2 caracteres dispara busca após 500ms de debounce',
    () async {
      bookApiRepository.books = <BookItem>[
        BookItem(id: '1', title: 'Dune', authors: 'Frank Herbert'),
      ];

      vm.onBookTitleChanged('Dune');

      expect(bookApiRepository.searchCallCount, 0);

      await Future.delayed(const Duration(milliseconds: 600));

      expect(bookApiRepository.searchCallCount, 1);
      expect(bookApiRepository.lastQuery, 'Dune');
      expect(vm.searchState, BookSearchState.results);
      expect(vm.searchResults.length, 1);
    },
  );

  test('busca sem resultados define o estado como empty', () async {
    vm.onBookTitleChanged('xyz');

    await Future.delayed(const Duration(milliseconds: 600));

    expect(bookApiRepository.searchCallCount, 1);
    expect(vm.searchState, BookSearchState.empty);
    expect(vm.searchResults, isEmpty);
  });

  test(
    'selectBook define o livro selecionado, o título e reseta o estado de busca',
    () {
      final book = BookItem(
        id: '1',
        title: 'Dune',
        authors: 'Frank Herbert',
      );
      vm.searchResults = <BookItem>[book];
      vm.searchState = BookSearchState.results;

      vm.selectBook(book);

      expect(vm.selectedBookItem, book);
      expect(vm.bookTitleInput.text, 'Dune');
      expect(vm.searchState, BookSearchState.idle);
      expect(vm.searchResults, isEmpty);
    },
  );

  test(
    'erro em searchBooks define o estado como error sem propagar exceção',
    () async {
      bookApiRepository.shouldThrow = true;

      vm.onBookTitleChanged('Dune');

      await Future.delayed(const Duration(milliseconds: 600));

      expect(vm.searchState, BookSearchState.error);
    },
  );

  test('isValid é false quando não há livro selecionado', () {
    vm.bookTitleInput.text = 'Dune';
    vm.startDateInput.value = DateTime(2024, 1, 1);
    vm.endDateInput.value = DateTime(2024, 2, 1);

    expect(vm.isValid, isFalse);
  });

  test(
    'isValid é true com livro selecionado, título válido e datas válidas',
    () {
      vm.selectedBookItem = BookItem(id: '1', title: 'Dune');
      vm.bookTitleInput.text = 'Dune';
      vm.startDateInput.value = DateTime(2024, 1, 1);
      vm.endDateInput.value = DateTime(2024, 2, 1);

      expect(vm.isValid, isTrue);
    },
  );
}
