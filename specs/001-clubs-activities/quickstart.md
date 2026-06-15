# Quickstart: Club Activities Feed Implementation

**Branch**: `feat/activities` | **Date**: 2026-06-08

## Prerequisites

- Flutter SDK ^3.7.2
- Backend running with updated Activities API (see `updated-manual.md`)
- Auth token available via `AuthRepository`

## Implementation Order

### Step 1: Update Domain Models

Add nullable enriched fields to activity entities. Run after all model changes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Files to modify (in order):

1. `lib/domain/activities/club_activities/entities/club_activity.dart` — add `clubName`, `clubPhotoUrl`
2. `lib/domain/activities/club_activities/entities/meeting_defined_activity.dart` — add enriched fields
3. `lib/domain/activities/club_activities/entities/member_completed_reading_activity.dart` — add enriched fields
4. `lib/domain/activities/club_activities/entities/reading_goal_defined_activity.dart` — add enriched fields
5. `lib/domain/activities/user_activities/entities/user_completed_reading_activity.dart` — add enriched fields

### Step 2: Update Repository

Modify `lib/infra/activities/activities_repository.dart`:

- Add optional `List<ActivityType>? types` parameter to all three `find*` methods
- Build repeated `type` query params from enum values
- Fix `findActivitiesForUser`: remove `userId` query param (backend uses auth token)

### Step 3: Refactor Card Widgets

Modify card base widgets to accept enriched data directly:

1. `_club_activity_card_widget.dart` — accept `String? clubName`, `String? clubPhotoUrl`, `String? bookTitle`, `String? bookCoverUrl` instead of `Club` and `BookItem` objects
2. `_user_activity_card_widget.dart` — accept `String? bookTitle`, `String? bookCoverUrl` instead of `BookItem` object

Simplify concrete card widgets (remove `AsyncBuilder` + `_getDependencies`):

3. `_meeting_defined_activity_card_widget.dart`
4. `_member_completed_reading_activity_card_widget.dart`
5. `_reading_goal_defined_activity_card_widget.dart`
6. `_user_completed_reading_activity_card_widget.dart`

### Step 4: Verify

```bash
flutter analyze
flutter run
```

## Key Patterns

### Type filter in repository

```dart
Future<Paginator<Activity>> findActivitiesByClubId(
  String clubId,
  int pageSize, {
  List<ActivityType>? types,
}) async {
  final authToken = (await _authRepository.getAuthData())!.token;

  return Paginator.create(pageSize, (page, pageSize) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'size': pageSize.toString(),
    };

    if (types != null) {
      for (final type in types) {
        // Add repeated 'type' params
        queryParams.addAll({'type': _activityTypeToString(type)});
      }
    }

    final uri = Uri.parse('$_apiUrl/api/v1/clubs/$clubId/activities')
        .replace(queryParameters: queryParams);
    // ... rest of request
  });
}
```

### Simplified card widget (before/after)

**Before** (with AsyncBuilder + multi-fetch):
```dart
Widget build(BuildContext context) {
  return AsyncBuilder(
    future: _getDependencies(context), // fetches Club, User, Book separately
    onRetrieved: (data) => _buildCard(context, data),
    onLoading: () => const Card(),
    onError: (_, __) => const Card(),
  );
}
```

**After** (data already in entity):
```dart
Widget build(BuildContext context) {
  return ClubActivityCardWidget(
    title: 'Atividade: Leitura Concluída por Membro',
    clubName: activity.clubName,
    clubPhotoUrl: activity.clubPhotoUrl,
    bookTitle: activity.bookTitle,
    bookCoverUrl: activity.bookCoverUrl,
    activity: activity,
    showClubHeader: showClubHeader,
    children: [
      // ... use activity.userName, activity.bookTitle directly
    ],
  );
}
```

## Nullable Field Handling

All enriched fields are nullable. Card widgets should handle null gracefully:

```dart
// Book title — show placeholder if null
Text(activity.bookTitle ?? 'Livro indisponível')

// Book cover — use placeholder asset if null
Image.network(
  activity.bookCoverUrl ?? 'assets/images/default_book_cover.png',
  errorBuilder: (_, __, ___) => Image.asset('assets/images/default_book_cover.png'),
)

// Date range — show only if both dates available
if (activity.startDate != null && activity.endDate != null)
  Text('${activity.startDate} — ${activity.endDate}')
```
