import 'package:booklub/domain/activities/entities/activity.dart';
import 'package:booklub/domain/entities/clubs/club.dart';
import 'package:booklub/domain/entities/books/book_item.dart';
import 'package:booklub/domain/entities/users/user.dart';
import 'package:booklub/domain/meetings/entities/meeting.dart';
import 'package:booklub/domain/reading_goals/entities/reading_goal.dart';
import 'package:booklub/domain/reading_goals/entities/reading_goal_with_book.dart';
import 'package:booklub/infra/activities/activities_repository.dart';
import 'package:booklub/infra/books/book_api_repository.dart';
import 'package:booklub/infra/clubs/club_repository.dart';
import 'package:booklub/infra/meetings/meetings_repository.dart';
import 'package:booklub/infra/reading_goals/reading_goals_repository.dart';
import 'package:booklub/ui/core/view_models/async_change_notifier.dart';
import 'package:booklub/ui/core/view_models/auth_view_model.dart';
import 'package:booklub/utils/pagination/page.dart';
import 'package:booklub/utils/pagination/paginator.dart';

class ClubProfileViewModel extends AsyncChangeNotifier {

  // ### Dependencies
  final ClubRepository _clubRepository;

  final ReadingGoalsRepository _readingGoalsRepository;

  final MeetingsRepository _meetingsRepository;

  final ActivitiesRepository _activitiesRepository;

  final BookApiRepository _bookApiRepository;

  final AuthViewModel _authViewModel;

  final String clubId;

  // ### Constructors
  ClubProfileViewModel({
    required ClubRepository clubRepository,
    required ReadingGoalsRepository readingGoalsRepository,
    required MeetingsRepository meetingsRepository,
    required ActivitiesRepository activityRepository,
    required BookApiRepository bookApiRepository,
    required AuthViewModel authViewModel,
    required this.clubId,
  }):
    _clubRepository = clubRepository,
    _readingGoalsRepository = readingGoalsRepository,
    _meetingsRepository = meetingsRepository,
    _activitiesRepository = activityRepository,
    _bookApiRepository = bookApiRepository,
    _authViewModel = authViewModel
  {
    _setClub(clubId);
  }

  Club? _club;

  @override
  Club? get payload => _club;

  int? _totalReadingGoals;
  int? _totalPendingRequests;

  int? get totalReadingGoals => _totalReadingGoals;
  int? get totalPendingRequests => _totalPendingRequests;

  Club? get club => payload;

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> _setClub(String clubId) async {
    if (_disposed) return;

    clubId = clubId;
    isLoading = true;
    notifyListeners();

    try {
      _club = await _clubRepository.findClubById(clubId);
      if (_disposed) return;
      await loadClubStats();
    } catch (e, trace) {
      error = (object: e, stackTrace: trace);
      _club = null;
    } finally {
      if (!_disposed) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  void checkClubLoaded() {
    if (club == null) throw StateError('Club with id $clubId was not loaded');
  }

  // ### Methods
  Future<Paginator<User>> getClubMembers(int pageSize) {
    return _clubRepository.findClubMembers(pageSize, clubId);
  }

  Future<bool> isLoggedUserClubAdmin() async {
    checkClubLoaded();
    return club!.ownerId == (await _authViewModel.authData)!.user.id;
  }

  Future<Paginator<ReadingGoal>> getClubReadingGoals(int pageSize) async {
    return _readingGoalsRepository.findReadingGoalsByClubId(clubId, pageSize);
  }

  Future<int> getClubReadingGoalsCount() async {
    final paginator = await getClubReadingGoals(1);
    return paginator.totalElements;
  }

  Future<Paginator<ReadingGoalWithBook>> getClubReadingGoalsWithBooks(int pageSize) async {
    final goalsPaginator = await getClubReadingGoals(pageSize);

    return Paginator.create(pageSize, (page, pageSize) async {
      final pageGoals = await goalsPaginator[page];
      final enrichedGoals = await Future.wait(
        pageGoals.content.map((goal) async {
          try {
            final book = await _bookApiRepository.getBookById(goal.bookId);
            return ReadingGoalWithBook.fromReadingGoal(goal, book);
          } catch (e) {
            // If book fetch fails, return goal with empty book
            return ReadingGoalWithBook.fromReadingGoal(
              goal,
              BookItem(title: goal.bookId),
            );
          }
        }),
      );

      return Page(
        content: enrichedGoals,
        pageInfo: pageGoals.pageInfo,
      );
    });
  }

  Future<Paginator<Meeting>> getClubMeetings(int pageSize) async {
    return _meetingsRepository.findMeetingsByClubId(clubId, pageSize);
  }

  Future<Paginator<Activity>> getClubActivities(
    int pageSize, {
    List<ActivityType>? types,
  }) async {
    return _activitiesRepository.findActivitiesByClubId(
      clubId, pageSize, types: types,
    );
  }

  Future<void> loadClubStats() async {
    try {
      final readingGoalsPaginator = await getClubReadingGoals(1);
      _totalReadingGoals = readingGoalsPaginator.totalElements;
    } catch (e) {
      _totalReadingGoals = 0;
    }

    try {
      final isAdmin = await isLoggedUserClubAdmin();
      if (isAdmin) {
        final pendingRequestsPaginator = await getClubPendingRequests(1);
        _totalPendingRequests = pendingRequestsPaginator.totalElements;
      } else {
        _totalPendingRequests = 0;
      }
    } catch (e) {
      _totalPendingRequests = 0;
    }

    notifyListeners();
  }

  Future<Paginator<dynamic>> getClubPendingRequests(int pageSize) async {
    return _clubRepository.findPendingRequests(clubId, pageSize);
  }

  Future<void> acceptRequest(String userId) async {
    checkClubLoaded();
    await _clubRepository.acceptRequest(clubId, userId);

    // Reload stats to update counts
    await loadClubStats();
  }

  Future<void> denyRequest(String userId) async {
    checkClubLoaded();
    await _clubRepository.denyRequest(clubId, userId);

    // Reload stats to update counts
    await loadClubStats();
  }

}