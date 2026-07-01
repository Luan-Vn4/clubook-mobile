import 'package:booklub/domain/entities/books/book_item.dart';
import 'package:booklub/domain/entities/users/auth_data.dart';
import 'package:booklub/domain/entities/users/auth_token.dart';
import 'package:booklub/domain/entities/users/user.dart';
import 'package:booklub/domain/entities/users/user_creation_dto.dart';
import 'package:booklub/domain/geocoding/gateways/geocoding_gateway.dart';
import 'package:booklub/domain/geocoding/models/geocoding_result.dart';
import 'package:booklub/domain/meetings/entities/meeting.dart';
import 'package:booklub/domain/meetings/entities/meeting_creation_dto.dart';
import 'package:booklub/domain/reading_goals/entities/reading_goal.dart';
import 'package:booklub/domain/reading_goals/entities/reading_goal_creation_dto.dart';
import 'package:booklub/domain/reading_goals/entities/reading_goal_with_book.dart';
import 'package:booklub/infra/auth/auth_repository.dart';
import 'package:booklub/infra/books/book_api_repository.dart';
import 'package:booklub/infra/meetings/meetings_repository.dart';
import 'package:booklub/infra/reading_goals/reading_goals_repository.dart';
import 'package:booklub/ui/clubs/meetings/widgets/reading_goal_selector.dart';
import 'package:booklub/ui/core/view_models/creating_meeting_view_model.dart';
import 'package:booklub/utils/geo/types/latlng.dart';
import 'package:booklub/utils/pagination/page.dart';
import 'package:booklub/utils/pagination/paginator.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_test/flutter_test.dart';

class _FakeAuthRepository implements AuthRepository {
  AuthData? authData;

  @override
  Future<AuthData?> getAuthData() async => authData;

  @override
  Future<AuthData> login(String username, String password) =>
      throw UnimplementedError();

  @override
  Future<void> recoverPasswordViaEmail(String email) =>
      throw UnimplementedError();

  @override
  Future<void> register(UserCreationDTO dto) => throw UnimplementedError();

  @override
  Future<void> saveAuthData(AuthData authData) => throw UnimplementedError();

  @override
  Future<void> clearAuthData() => throw UnimplementedError();
}

class _FakeMeetingsRepository implements MeetingsRepository {
  MeetingCreationDto? lastDto;
  Meeting meetingToReturn = Meeting(
    id: 'meeting-1',
    readingGoalId: 'rg-1',
    clubId: 'club-1',
    address: 'addr',
    latlng: LatLng(latitude: 1, longitude: 2),
    date: DateTime(2024, 1, 1),
    createdAt: DateTime(2024, 1, 1),
  );

  @override
  Future<Meeting> createMeeting(MeetingCreationDto dto) async {
    lastDto = dto;
    return meetingToReturn;
  }

  @override
  Future<Paginator<Meeting>> findMeetingsByClubId(String clubId, int pageSize) =>
      throw UnimplementedError();

  @override
  Future<Meeting> findNextMeetingByClubId(String clubId) =>
      throw UnimplementedError();

  @override
  Future<Meeting> findMeetingByReadingGoalId(String readingGoalId) =>
      throw UnimplementedError();

  @override
  Future<Meeting> findMeetingById(String meetingId) => throw UnimplementedError();
}

class _FakeBookApiRepository implements BookApiRepository {
  final Set<String> failingBookIds;

  _FakeBookApiRepository({this.failingBookIds = const <String>{}});

  @override
  Future<BookItem> getBookById(String volumeId) async {
    if (failingBookIds.contains(volumeId)) {
      throw Exception('boom for $volumeId');
    }
    return BookItem(id: volumeId, title: 'Book-$volumeId');
  }

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
  }) =>
      throw UnimplementedError();
}

class _FakeReadingGoalsRepository implements ReadingGoalsRepository {
  List<ReadingGoal> goals = const <ReadingGoal>[];
  int currentGoalCalls = 0;

  @override
  Future<Paginator<ReadingGoal>> findReadingGoalsByClubId(
    String clubId,
    int pageSize,
  ) async {
    return Paginator.create<ReadingGoal>(pageSize, (page, size) async {
      return Page<ReadingGoal>(
        content: List<ReadingGoal>.from(goals),
        pageInfo: PageInfo(
          size: pageSize,
          number: 0,
          totalElements: goals.length,
          totalPages: 1,
        ),
      );
    });
  }

  @override
  Future<ReadingGoal> findClubCurrentReadingGoal(String clubId) async {
    currentGoalCalls++;
    throw Exception('should not be called');
  }

  @override
  Future<ReadingGoal> createReadingGoal(
          CreateReadingGoalDto readingGoal, String clubId) =>
      throw UnimplementedError();

  @override
  Future<ReadingGoal> findById(String readingGoalId) =>
      throw UnimplementedError();
}

class _FakeGeocodingGateway implements GeocodingGateway {
  List<GeocodingResult> forwardResults = const <GeocodingResult>[];
  GeocodingResult? reverseResult;
  int forwardCallCount = 0;
  int reverseCallCount = 0;

  @override
  Future<List<GeocodingResult>> searchByAddress({
    required String query,
    int limit = 5,
  }) async {
    forwardCallCount++;
    return forwardResults;
  }

  @override
  Future<GeocodingResult?> reverse({
    required double latitude,
    required double longitude,
  }) async {
    reverseCallCount++;
    return reverseResult;
  }
}

ReadingGoal _goal({required String id, required String bookId}) => ReadingGoal(
      id: id,
      bookId: bookId,
      clubId: 'club-1',
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 2, 1),
      createdAt: DateTime(2024, 1, 1),
    );

CreateMeetingViewModel _buildVm({
  required _FakeReadingGoalsRepository readingGoals,
  required _FakeBookApiRepository books,
  _FakeGeocodingGateway? geocoding,
  _FakeMeetingsRepository? meetings,
  _FakeAuthRepository? auth,
}) {
  return CreateMeetingViewModel(
    authRepository: auth ?? _FakeAuthRepository(),
    meetingsRepository: meetings ?? _FakeMeetingsRepository(),
    bookApiRepository: books,
    readingGoalsRepository: readingGoals,
    clubId: 'club-1',
    geocodingGateway: geocoding ?? _FakeGeocodingGateway(),
  );
}

void main() {
  late _FakeAuthRepository auth;
  late _FakeMeetingsRepository meetings;
  late _FakeBookApiRepository books;
  late _FakeReadingGoalsRepository readingGoals;
  late _FakeGeocodingGateway geocoding;

  setUp(() {
    auth = _FakeAuthRepository();
    auth.authData = AuthData(
      user: User(
        id: 'u1',
        username: 'user',
        email: 'user@example.com',
        firstName: 'First',
        lastName: 'Last',
        imageUrl: null,
      ),
      token: AuthToken(
        accessToken: 'token',
        expiration: DateTime(2025, 1, 1),
        tokenType: 'Bearer',
      ),
    );
    meetings = _FakeMeetingsRepository();
    books = _FakeBookApiRepository();
    readingGoals = _FakeReadingGoalsRepository();
    geocoding = _FakeGeocodingGateway();
  });

  group('loadReadingGoals', () {
    test('success enriches goals with book titles and sets loaded state', () async {
      readingGoals.goals = <ReadingGoal>[
        _goal(id: 'rg-1', bookId: 'b1'),
        _goal(id: 'rg-2', bookId: 'b2'),
      ];
      final vm = _buildVm(
        auth: auth,
        meetings: meetings,
        books: books,
        readingGoals: readingGoals,
        geocoding: geocoding,
      );

      await vm.loadReadingGoals();

      expect(vm.goalsLoadState, ReadingGoalsLoadState.loaded);
      expect(vm.readingGoals, hasLength(2));
      expect(vm.readingGoals[0].book.title, 'Book-b1');
      expect(vm.readingGoals[1].book.title, 'Book-b2');
    });

    test('empty goals list sets empty state', () async {
      readingGoals.goals = const <ReadingGoal>[];
      final vm = _buildVm(
        auth: auth,
        meetings: meetings,
        books: books,
        readingGoals: readingGoals,
        geocoding: geocoding,
      );

      await vm.loadReadingGoals();

      expect(vm.goalsLoadState, ReadingGoalsLoadState.empty);
      expect(vm.readingGoals, isEmpty);
    });

    test('a failing book enrichment falls back to placeholder without failing the load', () async {
      readingGoals.goals = <ReadingGoal>[
        _goal(id: 'rg-1', bookId: 'b1'),
        _goal(id: 'rg-2', bookId: 'b2-FAIL'),
      ];
      books = _FakeBookApiRepository(failingBookIds: <String>{'b2-FAIL'});
      final vm = _buildVm(
        auth: auth,
        meetings: meetings,
        books: books,
        readingGoals: readingGoals,
        geocoding: geocoding,
      );

      await vm.loadReadingGoals();

      expect(vm.goalsLoadState, ReadingGoalsLoadState.loaded);
      expect(vm.readingGoals, hasLength(2));
      expect(vm.readingGoals[0].book.title, 'Book-b1');
      expect(vm.readingGoals[1].book.title, '—');
    });
  });

  group('selectReadingGoal', () {
    test('sets and replaces the selected reading goal', () {
      final vm = _buildVm(
        auth: auth,
        meetings: meetings,
        books: books,
        readingGoals: readingGoals,
        geocoding: geocoding,
      );
      final first = ReadingGoalWithBook.fromReadingGoal(
        _goal(id: 'rg-1', bookId: 'b1'),
        BookItem(title: 'A'),
      );
      final second = ReadingGoalWithBook.fromReadingGoal(
        _goal(id: 'rg-2', bookId: 'b2'),
        BookItem(title: 'B'),
      );

      vm.selectReadingGoal(first);
      expect(vm.selectedReadingGoal?.id, 'rg-1');

      vm.selectReadingGoal(second);
      expect(vm.selectedReadingGoal?.id, 'rg-2');
    });
  });

  group('searchAddress', () {
    test('queries under 3 characters do not invoke the gateway', () async {
      final vm = _buildVm(
        auth: auth,
        meetings: meetings,
        books: books,
        readingGoals: readingGoals,
        geocoding: geocoding,
      );

      await vm.searchAddress('ab');
      await Future<void>.delayed(const Duration(milliseconds: 600));

      expect(geocoding.forwardCallCount, 0);
      expect(vm.latlngInput.value, isNull);
    });

    test('a valid query exposes results after the debounce window', () async {
      geocoding.forwardResults = <GeocodingResult>[
        const GeocodingResult(address: 'Dune', latitude: 1, longitude: 2),
      ];
      final vm = _buildVm(
        auth: auth,
        meetings: meetings,
        books: books,
        readingGoals: readingGoals,
        geocoding: geocoding,
      );

      await vm.searchAddress('Dune');
      expect(vm.latlngInput.value, isNull);

      await Future<void>.delayed(const Duration(milliseconds: 600));
      await Future<void>.delayed(Duration.zero);

      expect(geocoding.forwardCallCount, 1);
      expect(vm.locationSearchState, LocationSearchState.results);
      expect(vm.locationResults, hasLength(1));
      expect(vm.locationResults.first.address, 'Dune');
      expect(vm.latlngInput.value, isNull);
    });
  });

  group('onMapTapped', () {
    test('sets latlng and reverse-geocodes into the address field', () async {
      geocoding.reverseResult = const GeocodingResult(
        address: 'Somewhere',
        latitude: 10,
        longitude: 20,
      );
      final vm = _buildVm(
        auth: auth,
        meetings: meetings,
        books: books,
        readingGoals: readingGoals,
        geocoding: geocoding,
      );

      await vm.onMapTapped(LatLng(latitude: 10, longitude: 20));

      expect(vm.latlngInput.value, isNotNull);
      expect(vm.latlngInput.value!.latitude, 10);
      expect(vm.latlngInput.value!.longitude, 20);
      expect(vm.addressInput.text, 'Somewhere');
      expect(geocoding.reverseCallCount, 1);
    });
  });

  group('isValid', () {
    late ReadingGoalWithBook goal;

    setUp(() {
      goal = ReadingGoalWithBook.fromReadingGoal(
        _goal(id: 'rg-1', bookId: 'b1'),
        BookItem(title: 'A'),
      );
    });

    test('true when every required field is set', () {
      final vm = _buildVm(
        auth: auth,
        meetings: meetings,
        books: books,
        readingGoals: readingGoals,
        geocoding: geocoding,
      );
      vm.addressInput.text = 'Rua A';
      vm.dateInput.value = DateTime(2024, 3, 1);
      vm.timeInput.value = const TimeOfDay(hour: 10, minute: 0);
      vm.latlngInput.value = LatLng(latitude: 1, longitude: 2);
      vm.selectReadingGoal(goal);

      expect(vm.isValid, isTrue);
    });

    test('false when address is empty', () {
      final vm = _buildVm(
        auth: auth,
        meetings: meetings,
        books: books,
        readingGoals: readingGoals,
        geocoding: geocoding,
      );
      vm.dateInput.value = DateTime(2024, 3, 1);
      vm.timeInput.value = const TimeOfDay(hour: 10, minute: 0);
      vm.latlngInput.value = LatLng(latitude: 1, longitude: 2);
      vm.selectReadingGoal(goal);

      expect(vm.isValid, isFalse);
    });

    test('false when latlng is null', () {
      final vm = _buildVm(
        auth: auth,
        meetings: meetings,
        books: books,
        readingGoals: readingGoals,
        geocoding: geocoding,
      );
      vm.addressInput.text = 'Rua A';
      vm.dateInput.value = DateTime(2024, 3, 1);
      vm.timeInput.value = const TimeOfDay(hour: 10, minute: 0);
      vm.selectReadingGoal(goal);

      expect(vm.isValid, isFalse);
    });

    test('false when no reading goal is selected', () {
      final vm = _buildVm(
        auth: auth,
        meetings: meetings,
        books: books,
        readingGoals: readingGoals,
        geocoding: geocoding,
      );
      vm.addressInput.text = 'Rua A';
      vm.dateInput.value = DateTime(2024, 3, 1);
      vm.timeInput.value = const TimeOfDay(hour: 10, minute: 0);
      vm.latlngInput.value = LatLng(latitude: 1, longitude: 2);

      expect(vm.isValid, isFalse);
    });
  });

  group('createMeeting', () {
    test('uses selectedReadingGoal.id and never looks up the current goal', () async {
      readingGoals.goals = <ReadingGoal>[_goal(id: 'rg-1', bookId: 'b1')];
      final vm = _buildVm(
        auth: auth,
        meetings: meetings,
        books: books,
        readingGoals: readingGoals,
        geocoding: geocoding,
      );
      await vm.loadReadingGoals();
      vm.selectReadingGoal(vm.readingGoals.first);
      vm.addressInput.text = 'Rua A';
      vm.dateInput.value = DateTime(2024, 3, 1);
      vm.timeInput.value = const TimeOfDay(hour: 10, minute: 0);
      vm.latlngInput.value = LatLng(latitude: 5, longitude: 6);

      final success = await vm.createMeeting();

      expect(success, isTrue);
      expect(meetings.lastDto, isNotNull);
      expect(meetings.lastDto!.readingGoalId, 'rg-1');
      expect(meetings.lastDto!.latlng.latitude, 5);
      expect(meetings.lastDto!.latlng.longitude, 6);
      expect(readingGoals.currentGoalCalls, 0);
    });

    test('returns false when the form is invalid', () async {
      final vm = _buildVm(
        auth: auth,
        meetings: meetings,
        books: books,
        readingGoals: readingGoals,
        geocoding: geocoding,
      );

      final success = await vm.createMeeting();

      expect(success, isFalse);
      expect(meetings.lastDto, isNull);
    });
  });
}
