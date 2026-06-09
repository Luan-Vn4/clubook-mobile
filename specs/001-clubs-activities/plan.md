# Implementation Plan: Club Activities Feed

**Branch**: `feat/activities` | **Date**: 2026-06-08 | **Spec**: `specs/001-clubs-activities/spec.md`

**Input**: Feature specification from `specs/001-clubs-activities/spec.md`

**Backend Reference**: `updated-manual.md` (enriched DTOs + server-side type filtering)

## Summary

Implement the Club Activities Feed feature, adapting to the updated backend API that now returns **enriched activity DTOs** (embedded book, club, user display data) and supports **server-side type filtering** via the `type` query parameter.

The primary impact is a **significant simplification** of the mobile client:
- Activity card widgets no longer need multi-fetch dependency resolution via `AsyncBuilder`
- Domain models gain nullable enriched fields matching the backend DTOs
- Repository methods gain optional `type` filter parameters
- The `ClubActivityCardWidget` and `UserActivityCardWidget` base widgets are refactored to accept enriched DTO data directly

## Technical Context

**Language/Version**: Dart (Flutter SDK ^3.7.2)

**Primary Dependencies**: Flutter, Provider ^6.1.4, GoRouter ^15.1.1, http ^1.4.0, json_annotation ^4.9.0, json_serializable ^6.9.5

**Storage**: N/A (server-fetched data, no local persistence)

**Testing**: flutter_test

**Target Platform**: Android / iOS (mobile app)

**Project Type**: mobile-app

**Performance Goals**: 60 fps scroll, progressive pagination, <500ms first activity card render

**Constraints**: All enriched fields nullable (backend may return null if Google Books API unreachable)

**Scale/Scope**: ~6 domain model files, ~8 UI card widget files, 1 repository

### Backend API (updated)

| Endpoint | Description | Key Change |
|----------|-------------|------------|
| `GET /api/v1/activities` | Home feed (auth user's clubs) | Returns only `ClubActivity`; uses auth token (no `userId` param) |
| `GET /api/v1/clubs/{clubId}/activities` | Club-specific feed | Supports `?type=` filter |
| `GET /api/v1/users/{userId}/activities` | User-specific feed | Supports `?type=` filter |

### DTO Enrichment (old → new)

| Activity Type | Old Fields | New Enriched Fields |
|---|---|---|
| `MeetingDefinedActivity` | `meetingId`, `clubId` | +`clubName`, `clubPhotoUrl`, `meetingAddress`, `meetingDate`, `bookId`, `bookTitle`, `bookCoverUrl` |
| `MemberCompletedReadingActivity` | `userId`, `bookId`, `clubId` | +`clubName`, `clubPhotoUrl`, `userName`, `userAvatarUrl`, `startDate`, `endDate`, `bookTitle`, `bookCoverUrl` |
| `ReadingGoalDefinedActivity` | `readingGoalId`, `clubId` | +`clubName`, `clubPhotoUrl`, `goalStartDate`, `goalEndDate`, `bookTitle`, `bookCoverUrl` |
| `UserCompletedReadingActivity` | `userId`, `bookId` | +`bookTitle`, `bookCoverUrl`, `startDate`, `endDate` |

### Existing Code to Modify

| File | Change Type |
|------|------------|
| `lib/domain/activities/club_activities/entities/club_activity.dart` | Add `clubName`, `clubPhotoUrl` |
| `lib/domain/activities/club_activities/entities/meeting_defined_activity.dart` | Add enriched fields |
| `lib/domain/activities/club_activities/entities/member_completed_reading_activity.dart` | Add enriched fields |
| `lib/domain/activities/club_activities/entities/reading_goal_defined_activity.dart` | Add enriched fields |
| `lib/domain/activities/user_activities/entities/user_completed_reading_activity.dart` | Add enriched fields |
| `lib/infra/activities/activities_repository.dart` | Add `type` filter params, fix home feed |
| `lib/ui/core/widgets/cards/activity_cards/_club_activity_card_widget.dart` | Refactor: accept enriched data |
| `lib/ui/core/widgets/cards/activity_cards/_user_activity_card_widget.dart` | Refactor: accept enriched data |
| `lib/ui/core/widgets/cards/activity_cards/_meeting_defined_activity_card_widget.dart` | Remove `AsyncBuilder` + multi-fetch |
| `lib/ui/core/widgets/cards/activity_cards/_member_completed_reading_activity_card_widget.dart` | Remove `AsyncBuilder` + multi-fetch |
| `lib/ui/core/widgets/cards/activity_cards/_reading_goal_defined_activity_card_widget.dart` | Remove `AsyncBuilder` + multi-fetch |
| `lib/ui/core/widgets/cards/activity_cards/_user_completed_reading_activity_card_widget.dart` | Remove `AsyncBuilder` + multi-fetch |

### Existing Code (no change needed)

| File | Reason |
|------|--------|
| `lib/utils/pagination/page.dart` | Pagination structure matches `PagedModel` |
| `lib/utils/pagination/paginator.dart` | Generic paginator works as-is |
| `lib/domain/activities/entities/activity.dart` | Base `Activity` class + `ActivityType` enum + `fromJson` factory unchanged |
| `lib/ui/core/widgets/cards/activity_cards/activity_card_builder.dart` | Switch dispatch already correct |

### Spec Assumptions Updated

The following spec assumptions are now **invalid** due to backend changes:

| Old Assumption | New Reality |
|---|---|
| "The existing domain models contain reference IDs; the client is responsible for resolving them into display data." | Backend returns enriched DTOs with embedded display data. Client maps directly. |
| "Filter tabs on the club page filter on the client side after fetching all activities (the club activity endpoint has no type filter parameter)." | Backend now supports server-side `type` filtering on all endpoints. |
| "Separate endpoints exist for resolving referenced entities (meetings, users, books, reading goals, clubs)." | Not needed — data is embedded in activity responses. |

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Adapted MVVM | ✅ PASS | ViewModels call repositories; widgets consume ViewModel state |
| II. Layer Dependency | ✅ PASS | `ui` → `domain` ← `infra`; no cross-layer violations |
| III. Feature-Based UI | ✅ PASS | Activities under `lib/ui/` feature area |
| IV. Domain-First Contracts | ✅ PASS | Domain entities define the shape; infra maps from JSON |
| V. Simplicity (YAGNI) | ✅ PASS | Removing `AsyncBuilder` + multi-fetch simplifies cards considerably |
| No `any` types | ✅ PASS | All fields explicitly typed with nullability |
| `json_serializable` for models | ✅ PASS | Using `@JsonSerializable` with `build_runner` |

**Post-design reassessment**: The enriched DTOs eliminate the need for 4+ separate API calls per activity card, directly supporting Principle V (simplicity). The `type` filter eliminates client-side filtering logic.

## Project Structure

### Documentation (this feature)

```text
specs/001-clubs-activities/
├── spec.md                    # Feature specification
├── plan.md                    # This file
├── research.md                # Phase 0 research findings
├── data-model.md              # Domain entity definitions
├── quickstart.md              # Implementation quick reference
└── contracts/
    └── api-contracts.md       # API endpoint contracts
```

### Source Code (repository root)

```text
lib/
├── domain/activities/
│   ├── entities/
│   │   └── activity.dart                  # Base Activity + ActivityType enum (unchanged)
│   ├── club_activities/entities/
│   │   ├── club_activity.dart             # ADD: clubName, clubPhotoUrl
│   │   ├── meeting_defined_activity.dart  # ADD: enriched fields
│   │   ├── member_completed_reading_activity.dart  # ADD: enriched fields
│   │   └── reading_goal_defined_activity.dart      # ADD: enriched fields
│   └── user_activities/entities/
│       ├── user_activity.dart             # (unchanged)
│       └── user_completed_reading_activity.dart  # ADD: enriched fields
├── infra/activities/
│   └── activities_repository.dart         # ADD: type filter support, fix home feed
└── ui/core/widgets/cards/activity_cards/
    ├── activity_card_builder.dart         # (unchanged)
    ├── _club_activity_card_widget.dart    # REFACTOR: accept enriched data
    ├── _user_activity_card_widget.dart    # REFACTOR: accept enriched data
    ├── _meeting_defined_activity_card_widget.dart       # SIMPLIFY: remove AsyncBuilder
    ├── _member_completed_reading_activity_card_widget.dart  # SIMPLIFY: remove AsyncBuilder
    ├── _reading_goal_defined_activity_card_widget.dart      # SIMPLIFY: remove AsyncBuilder
    └── _user_completed_reading_activity_card_widget.dart    # SIMPLIFY: remove AsyncBuilder
```

**Structure Decision**: All changes fit within the existing domain → infra → ui layer structure. No new directories or files needed. The enriched DTOs flow from `infra` (JSON mapping) through `domain` (typed entities) to `ui` (card widgets).

## Complexity Tracking

| Metric | Value | Justification |
|--------|-------|---------------|
| Files modified | 12 | 5 domain models, 1 repository, 6 card widgets |
| Files created | 0 | No new files needed — existing structure covers all changes |
| New dependencies | 0 | All existing |
| Net lines removed | ~120 | AsyncBuilder + multi-fetch logic eliminated |
| Net lines added | ~60 | Enriched field declarations + repository type filter params |
| Risk level | Low | Backward-compatible field additions (all new fields nullable) |
