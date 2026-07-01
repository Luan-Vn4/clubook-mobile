import 'package:booklub/domain/entities/books/book_item.dart';
import 'package:booklub/domain/reading_goals/entities/reading_goal_with_book.dart';
import 'package:booklub/ui/clubs/meetings/widgets/reading_goal_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ReadingGoalWithBook makeGoal(
    String id,
    String title, {
    DateTime? start,
    DateTime? end,
  }) {
    final s = start ?? DateTime(2026, 1, 1);
    final e = end ?? DateTime(2026, 1, 31);
    return ReadingGoalWithBook(
      id: id,
      bookId: 'book-$id',
      clubId: 'club-1',
      startDate: s,
      endDate: e,
      createdAt: DateTime(2025, 1, 1),
      book: BookItem(id: 'book-$id', title: title),
    );
  }

  Finder fieldFinder() => find.byType(InputDecorator);

  Future<void> pumpSelector(
    WidgetTester tester, {
    required List<ReadingGoalWithBook> goals,
    required ReadingGoalsLoadState loadState,
    ReadingGoalWithBook? selected,
    ValueChanged<ReadingGoalWithBook>? onSelect,
    VoidCallback? onCreateReadingGoalTap,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReadingGoalSelector(
            goals: goals,
            selected: selected,
            onSelect: onSelect,
            loadState: loadState,
            onCreateReadingGoalTap: onCreateReadingGoalTap,
          ),
        ),
      ),
    );
  }

  testWidgets(
    'empty state renders message and create-goal button',
    (tester) async {
      await pumpSelector(
        tester,
        goals: const <ReadingGoalWithBook>[],
        loadState: ReadingGoalsLoadState.empty,
        onCreateReadingGoalTap: () {},
      );

      expect(
        find.text(
          'Você deve criar uma meta de leitura antes de criar encontros',
        ),
        findsOneWidget,
      );
      expect(find.text('Criar Meta de Leitura'), findsOneWidget);
    },
  );

  testWidgets(
    'empty state button fires onCreateReadingGoalTap',
    (tester) async {
      var tapped = false;
      await pumpSelector(
        tester,
        goals: const <ReadingGoalWithBook>[],
        loadState: ReadingGoalsLoadState.empty,
        onCreateReadingGoalTap: () => tapped = true,
      );

      await tester.tap(find.text('Criar Meta de Leitura'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    },
  );

  testWidgets(
    'loaded state renders field with label',
    (tester) async {
      final goals = <ReadingGoalWithBook>[
        makeGoal('g1', 'Dune'),
        makeGoal('g2', '1984'),
      ];
      await pumpSelector(
        tester,
        goals: goals,
        loadState: ReadingGoalsLoadState.loaded,
      );

      expect(fieldFinder(), findsOneWidget);
      expect(find.text('Meta de Leitura'), findsOneWidget);
    },
  );

  testWidgets(
    'tapping field opens overlay with formatted goal labels',
    (tester) async {
      final goals = <ReadingGoalWithBook>[
        makeGoal('g1', 'Dune'),
        makeGoal(
          'g2',
          '1984',
          start: DateTime(2026, 2, 1),
          end: DateTime(2026, 2, 28),
        ),
      ];
      await pumpSelector(
        tester,
        goals: goals,
        loadState: ReadingGoalsLoadState.loaded,
      );

      await tester.tap(fieldFinder());
      await tester.pumpAndSettle();

      expect(find.textContaining('Dune'), findsOneWidget);
      expect(find.textContaining('1984'), findsOneWidget);
      expect(find.textContaining('01/01/2026'), findsOneWidget);
      expect(find.textContaining('31/01/2026'), findsOneWidget);
      expect(find.textContaining('01/02/2026'), findsOneWidget);
      expect(find.textContaining('28/02/2026'), findsOneWidget);
    },
  );

  testWidgets(
    'selecting an overlay item calls onSelect with that goal',
    (tester) async {
      final goals = <ReadingGoalWithBook>[
        makeGoal('g1', 'Dune'),
        makeGoal('g2', '1984'),
      ];
      ReadingGoalWithBook? picked;
      await pumpSelector(
        tester,
        goals: goals,
        loadState: ReadingGoalsLoadState.loaded,
        onSelect: (ReadingGoalWithBook goal) => picked = goal,
      );

      await tester.tap(fieldFinder());
      await tester.pumpAndSettle();

      await tester.tap(find.textContaining('Dune').last);
      await tester.pumpAndSettle();

      expect(picked, isNotNull);
      expect(picked!.id, 'g1');
      expect(picked!.book.title, 'Dune');
    },
  );

  testWidgets(
    'passed selected goal is reflected in the field',
    (tester) async {
      final goals = <ReadingGoalWithBook>[
        makeGoal('g1', 'Dune'),
        makeGoal('g2', '1984'),
      ];
      await pumpSelector(
        tester,
        goals: goals,
        loadState: ReadingGoalsLoadState.loaded,
        selected: goals[0],
      );

      expect(find.textContaining('Dune'), findsOneWidget);
    },
  );
}
