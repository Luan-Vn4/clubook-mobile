# Tasks: Club Activities Feed

**Branch**: `feat/activities` | **Date**: 2026-06-08

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

| Alias | Resolves To |
|-------|-------------|
| `domain:activities` | `lib/domain/activities` |
| `domain:club_activities` | `lib/domain/activities/club_activities/entities` |
| `domain:user_activities` | `lib/domain/activities/user_activities/entities` |
| `infra:activities` | `lib/infra/activities` |
| `ui:cards` | `lib/ui/core/widgets/cards/activity_cards` |

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Update domain models with enriched fields and update repository for type filtering. These are prerequisites for ALL user stories.

- [x] T001 Add `clubName` (String?) and `clubPhotoUrl` (String?) nullable fields to `ClubActivity` abstract class in `lib/domain/activities/club_activities/entities/club_activity.dart`
- [x] T002 [P] Add enriched nullable fields (`meetingAddress`, `meetingDate`, `bookId`, `bookTitle`, `bookCoverUrl`) to `MeetingDefinedActivity` in `lib/domain/activities/club_activities/entities/meeting_defined_activity.dart`
- [x] T003 [P] Add enriched nullable fields (`startDate`, `endDate`, `userName`, `userAvatarUrl`, `bookTitle`, `bookCoverUrl`) to `MemberCompletedReadingActivity` in `lib/domain/activities/club_activities/entities/member_completed_reading_activity.dart`
- [x] T004 [P] Add enriched nullable fields (`goalStartDate`, `goalEndDate`, `bookTitle`, `bookCoverUrl`) to `ReadingGoalDefinedActivity` in `lib/domain/activities/club_activities/entities/reading_goal_defined_activity.dart`
- [x] T005 [P] Add enriched nullable fields (`startDate`, `endDate`, `bookTitle`, `bookCoverUrl`) to `UserCompletedReadingActivity` in `lib/domain/activities/user_activities/entities/user_completed_reading_activity.dart`
- [x] T006 Regenerate `.g.dart` files by running `dart run build_runner build --delete-conflicting-outputs` from project root
- [x] T007 Add optional `List<ActivityType>? types` parameter to `findActivitiesByClubId`, `findActivitiesByUserId`, and `findActivitiesForUser` methods in `lib/infra/activities/activities_repository.dart`. Build repeated `type` query params from enum values. Remove the `userId` query parameter from `findActivitiesForUser` (backend now uses auth token)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Refactor base card widget signatures to accept enriched data directly. These are shared by all concrete card widgets.

- [x] T008 Refactor `ClubActivityCardWidget` in `lib/ui/core/widgets/cards/activity_cards/_club_activity_card_widget.dart` — replace `Club club` param with `String? clubName` and `String? clubPhotoUrl`; replace `BookItem bookItem` param with `String? bookTitle` and `String? bookCoverUrl`; update the underlying `HorizontalClubContentCardWithBookCover` call to use these nullable strings
- [x] T009 Refactor `UserActivityCardWidget` in `lib/ui/core/widgets/cards/activity_cards/_user_activity_card_widget.dart` — replace `User user` param with `String? userName` and `String? userAvatarUrl`; replace `BookItem bookItem` param with `String? bookTitle` and `String? bookCoverUrl`; update the underlying `HorizontalUserContentCardWithBookCover` call to use these nullable strings

---

## Phase 3: User Story 1 - View All Activities on Club Page (Priority: P1) 🎯 MVP

**Story Goal**: Club member sees a scrollable feed of all activity cards (meetings, readings, reading goals) on the club profile page, loaded progressively with pagination.

**Independent Test**: Navigate to any club's profile page → verify mixed activity cards appear in a scrollable list ordered newest-to-oldest. Empty state shown when no activities exist.

### Implementation for User Story 1

- [x] T010 [US1] Simplify `MeetingDefinedActivityCardWidget` in `lib/ui/core/widgets/cards/activity_cards/_meeting_defined_activity_card_widget.dart` — remove `AsyncBuilder`, `_getDependencies`, and `_Dependencies` typedef; pass `activity.clubName`, `activity.clubPhotoUrl`, `activity.meetingAddress`, `activity.meetingDate`, `activity.bookTitle`, `activity.bookCoverUrl` directly to `ClubActivityCardWidget`; display placeholder text when enriched fields are null
- [x] T011 [P] [US1] Simplify `MemberCompletedReadingActivityCardWidget` in `lib/ui/core/widgets/cards/activity_cards/_member_completed_reading_activity_card_widget.dart` — remove `AsyncBuilder`, `_getDependencies`, and `_Dependencies` typedef; pass `activity.clubName`, `activity.clubPhotoUrl`, `activity.userName`, `activity.userAvatarUrl`, `activity.bookTitle`, `activity.bookCoverUrl` directly to `ClubActivityCardWidget`; display `activity.startDate`/`activity.endDate` when available
- [x] T012 [P] [US1] Simplify `ReadingGoalDefinedActivityCardWidget` in `lib/ui/core/widgets/cards/activity_cards/_reading_goal_defined_activity_card_widget.dart` — remove `AsyncBuilder`, `_getDependencies`, and `_Dependencies` typedef; pass `activity.clubName`, `activity.clubPhotoUrl`, `activity.goalStartDate`, `activity.goalEndDate`, `activity.bookTitle`, `activity.bookCoverUrl` directly to `ClubActivityCardWidget`; display date range when available
- [x] T013 [P] [US1] Simplify `UserCompletedReadingActivityWidget` in `lib/ui/core/widgets/cards/activity_cards/_user_completed_reading_activity_card_widget.dart` — remove `AsyncBuilder`, `_getDependencies`, and `_Dependencies` typedef; pass `activity.bookTitle`, `activity.bookCoverUrl` directly to `UserActivityCardWidget`; display placeholder when book info is null

---

## Phase 4: User Story 2 - Filter Activities by Type on Club Page (Priority: P2)

**Story Goal**: Club member can filter the activity feed by type using three tabs ("Atividades", "Leituras", "Encontros") with server-side filtering.

**Independent Test**: On the club page, tap each filter tab → verify correct activity subset is displayed. "Atividades" shows all, "Leituras" shows reading-related only, "Encontros" shows meetings only.

### Implementation for User Story 2

- [x] T014 [US2] Create an `ActivityFilter` enum (all, readings, meetings) in `lib/domain/activities/entities/activity_filter.dart` with a method to convert to `List<ActivityType>` for API calls — `readings` maps to `[memberCompletedReading, readingGoalDefined]`, `meetings` maps to `[meetingDefined]`, `all` maps to `null`
- [x] T015 [US2] Add filter tab bar widget ("Atividades", "Leituras", "Encontros") to the club page activities section in `lib/ui/clubs/club_profile_page.dart` (or the relevant club page widget) — use `SelectableButton` or equivalent with secondary color (#5966b1) for selected state and darkwhite (#cfcfcf) for unselected; default to "Atividades"; on tab change, re-fetch activities via `ActivitiesRepository.findActivitiesByClubId` with the appropriate `types` filter

---

## Phase 5: User Story 3 - View Activities on Homepage (Priority: P3)

**Story Goal**: User sees an "Atividades" section on the homepage with activity cards from all their clubs, each card showing the source club header.

**Independent Test**: Log in as a user who is a member of multiple clubs → verify homepage shows an "Atividades" section below the clubs carousel with cards displaying club photo, club name, and creation date.

### Implementation for User Story 3

- [x] T016 [US3] Add an "Atividades" section to the home page in `lib/ui/home/home_page.dart` (or the relevant home page widget) — place below the "Recentes" clubs carousel with a named section header matching that style; fetch activities using `ActivitiesRepository.findActivitiesForUser` with pagination; render cards via `ActivityCardBuilder` with `showAuthorHeader: true` so club headers are visible

---

## Phase 6: Polish & Cross-Cutting Concerns

- [x] T017 Audit all simplified card widgets for graceful null handling — ensure `bookTitle` shows "Livro indisponível" when null, `bookCoverUrl` falls back to a placeholder asset, `userName` shows "Usuário desconhecido" when null, and date ranges are only displayed when both start and end dates are non-null
- [x] T018 Run `flutter analyze` and fix any warnings or errors introduced by the changes; verify `dart run build_runner build --delete-conflicting-outputs` completes cleanly

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1 (Setup) → Phase 2 (Foundational) → Phase 3 (US1) → Phase 4 (US2)
                                                  ↓
                                              Phase 5 (US3)
                                                  ↓
                                              Phase 6 (Polish)
```

### User Story Dependencies

| Story | Depends On | Reason |
|-------|-----------|--------|
| US1 (P1) | Phase 1 + Phase 2 | Needs enriched domain models + refactored base widgets |
| US2 (P2) | US1 | Filtering adds tabs on top of the functional activity feed |
| US3 (P3) | US1 | Homepage reuses the same simplified card widgets |

### Within Each User Story

- **US1**: T010 → T011/T012/T013 (all parallel, different files)
- **US2**: T014 → T015 (enum first, then UI integration)
- **US3**: T016 (single task, self-contained)

### Parallel Opportunities

| Tasks | Reason |
|-------|--------|
| T002, T003, T004, T005 | Different entity files, no dependencies on each other |
| T010, T011, T012, T013 | Different card widget files, all depend on Phase 2 only |
| US2 + US3 | Can be done in parallel after US1 (different pages) |

---

## Parallel Example: User Story 1

```
After Phase 2 completes:
  ├── Agent A: T010 (MeetingDefinedActivity card)
  ├── Agent B: T011 (MemberCompletedReading card)
  ├── Agent C: T012 (ReadingGoalDefined card)
  └── Agent D: T013 (UserCompletedReading card)
```

## Implementation Strategy

### MVP First (User Story 1 Only)

Delivers immediate value: club activity feed with all enriched card types. After Phase 1–3, the club page shows a complete, paginated activity feed.

### Incremental Delivery

| Milestone | Stories | Value Delivered |
|-----------|---------|-----------------|
| MVP | US1 | Club page shows all activity cards with enriched data |
| V2 | US2 | Filter tabs added to club page |
| V3 | US3 | Activities appear on homepage |

### Parallel Team Strategy

After MVP (US1) is complete, US2 (club page filtering) and US3 (homepage section) can be developed in parallel since they touch different pages.

---

## Notes

- All enriched fields are nullable — backend may return `null` if Google Books API is unreachable
- No new dependencies or files needed (except the optional `ActivityFilter` enum in T014)
- The `activity_card_builder.dart` switch dispatch does NOT need changes — it already routes to the correct widget
- The `Activity.fromJson` polymorphic factory does NOT need changes — `json_serializable` handles new fields via `build_runner`
- The existing `Paginator<T>` and `Page<T>` utilities work as-is with the updated API responses
