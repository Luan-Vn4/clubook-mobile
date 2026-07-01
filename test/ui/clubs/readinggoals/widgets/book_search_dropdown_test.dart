import 'package:booklub/domain/entities/books/book_item.dart';
import 'package:booklub/ui/clubs/readinggoals/widgets/book_search_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildSubject(BookSearchDropdown widget) {
    return MaterialApp(home: Scaffold(body: widget));
  }

  testWidgets('error state renders the verbatim Portuguese message',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildSubject(
        BookSearchDropdown(
          results: const <BookItem>[],
          isLoading: false,
          hasError: true,
          onSelected: (_) {},
        ),
      ),
    );

    expect(find.text('Não foi possível buscar por livros'), findsOneWidget);
  });

  testWidgets('results list renders a ListTile per book',
      (WidgetTester tester) async {
    final books = <BookItem>[
      BookItem(title: 'Dune', authors: 'Frank Herbert'),
      BookItem(title: '1984', authors: 'George Orwell'),
    ];

    await tester.pumpWidget(
      buildSubject(
        BookSearchDropdown(
          results: books,
          isLoading: false,
          hasError: false,
          onSelected: (_) {},
        ),
      ),
    );

    expect(find.text('Dune'), findsOneWidget);
    expect(find.text('Frank Herbert'), findsOneWidget);
    expect(find.text('1984'), findsOneWidget);
    expect(find.text('George Orwell'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('loading state shows a CircularProgressIndicator',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildSubject(
        BookSearchDropdown(
          results: const <BookItem>[],
          isLoading: true,
          hasError: false,
          onSelected: (_) {},
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('tapping a row invokes onSelected with the tapped book',
      (WidgetTester tester) async {
    BookItem? selected;
    final books = <BookItem>[
      BookItem(title: 'Dune', authors: 'Frank Herbert'),
      BookItem(title: '1984', authors: 'George Orwell'),
    ];

    await tester.pumpWidget(
      buildSubject(
        BookSearchDropdown(
          results: books,
          isLoading: false,
          hasError: false,
          onSelected: (BookItem book) => selected = book,
        ),
      ),
    );

    await tester.tap(find.text('Dune'));
    await tester.pumpAndSettle();

    expect(selected, isNotNull);
    expect(selected!.title, 'Dune');
  });
}
