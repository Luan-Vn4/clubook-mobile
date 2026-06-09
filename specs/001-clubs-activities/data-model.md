# Data Model: Club Activities Feed

**Branch**: `feat/activities` | **Date**: 2026-06-08

## Entity Hierarchy

```
Activity (abstract)
├── ClubActivity (abstract, extends Activity)
│   ├── MeetingDefinedActivity
│   ├── MemberCompletedReadingActivity
│   └── ReadingGoalDefinedActivity
└── UserActivity (abstract, extends Activity)
    └── UserCompletedReadingActivity
```

## Activity (base — `lib/domain/activities/entities/activity.dart`)

No changes. Existing fields remain:

| Field | Type | Nullable | Source |
|-------|------|----------|--------|
| `id` | `String` | No | `ActivityDTO.id` |
| `createdAt` | `DateTime` | No | `ActivityDTO.createdAt` |
| `type` | `ActivityType` | No | `ActivityDTO.type` |

### ActivityType enum (unchanged)

| Dart value | JSON value | Category |
|------------|-----------|----------|
| `meetingDefined` | `MEETING_DEFINED` | ClubActivity |
| `memberCompletedReading` | `MEMBER_COMPLETED_READING` | ClubActivity |
| `readingGoalDefined` | `READING_GOAL_DEFINED` | ClubActivity |
| `userCompletedReading` | `USER_COMPLETED_READING` | UserActivity |

## ClubActivity (abstract — `club_activities/entities/club_activity.dart`)

**CHANGED**: Add two nullable enriched fields shared by all club activities.

| Field | Type | Nullable | Source | Change |
|-------|------|----------|--------|--------|
| `clubId` | `String` | No | `ClubActivityDTO.clubId` | existing |
| `clubName` | `String?` | Yes | `ClubActivityDTO.clubName` | **NEW** |
| `clubPhotoUrl` | `String?` | Yes | `ClubActivityDTO.clubPhotoUrl` | **NEW** |

## UserActivity (abstract — `user_activities/entities/user_activity.dart`)

No changes. Existing field:

| Field | Type | Nullable | Source |
|-------|------|----------|--------|
| `userId` | `String` | No | `UserActivityDTO.userId` |

## MeetingDefinedActivity — `club_activities/entities/meeting_defined_activity.dart`

**CHANGED**: Add enriched fields for meeting details and book info.

| Field | Type | Nullable | Source | Change |
|-------|------|----------|--------|--------|
| `meetingId` | `String` | No | `MeetingDefinedActivityDTO.meetingId` | existing |
| `meetingAddress` | `String?` | Yes | `MeetingDefinedActivityDTO.meetingAddress` | **NEW** |
| `meetingDate` | `String?` | Yes | `MeetingDefinedActivityDTO.meetingDate` | **NEW** |
| `bookId` | `String?` | Yes | `MeetingDefinedActivityDTO.bookId` | **NEW** |
| `bookTitle` | `String?` | Yes | `MeetingDefinedActivityDTO.bookTitle` | **NEW** |
| `bookCoverUrl` | `String?` | Yes | `MeetingDefinedActivityDTO.bookCoverUrl` | **NEW** |

> **Note**: `meetingDate` typed as `String?` (ISO local date `yyyy-MM-dd`) to avoid importing a date library. If `DateTime` or a `LocalDate` type is preferred, update accordingly.

## MemberCompletedReadingActivity — `club_activities/entities/member_completed_reading_activity.dart`

**CHANGED**: Add enriched fields for user, book, and reading goal dates.

| Field | Type | Nullable | Source | Change |
|-------|------|----------|--------|--------|
| `userId` | `String` | No | `MemberCompletedReadingActivityDTO.userId` | existing |
| `bookId` | `String` | No | `MemberCompletedReadingActivityDTO.bookId` | existing |
| `startDate` | `String?` | Yes | `MemberCompletedReadingActivityDTO.startDate` | **NEW** |
| `endDate` | `String?` | Yes | `MemberCompletedReadingActivityDTO.endDate` | **NEW** |
| `userName` | `String?` | Yes | `MemberCompletedReadingActivityDTO.userName` | **NEW** |
| `userAvatarUrl` | `String?` | Yes | `MemberCompletedReadingActivityDTO.userAvatarUrl` | **NEW** |
| `bookTitle` | `String?` | Yes | `MemberCompletedReadingActivityDTO.bookTitle` | **NEW** |
| `bookCoverUrl` | `String?` | Yes | `MemberCompletedReadingActivityDTO.bookCoverUrl` | **NEW** |

## ReadingGoalDefinedActivity — `club_activities/entities/reading_goal_defined_activity.dart`

**CHANGED**: Add enriched fields for reading goal details and book info.

| Field | Type | Nullable | Source | Change |
|-------|------|----------|--------|--------|
| `readingGoalId` | `String` | No | `ReadingGoalDefinedActivityDTO.readingGoalId` | existing |
| `goalStartDate` | `String?` | Yes | `ReadingGoalDefinedActivityDTO.goalStartDate` | **NEW** |
| `goalEndDate` | `String?` | Yes | `ReadingGoalDefinedActivityDTO.goalEndDate` | **NEW** |
| `bookTitle` | `String?` | Yes | `ReadingGoalDefinedActivityDTO.bookTitle` | **NEW** |
| `bookCoverUrl` | `String?` | Yes | `ReadingGoalDefinedActivityDTO.bookCoverUrl` | **NEW** |

## UserCompletedReadingActivity — `user_activities/entities/user_completed_reading_activity.dart`

**CHANGED**: Add enriched fields for book info and dates.

| Field | Type | Nullable | Source | Change |
|-------|------|----------|--------|--------|
| `bookId` | `String` | No | `UserCompletedReadingActivityDTO.bookId` | existing |
| `startDate` | `String?` | Yes | `UserCompletedReadingActivityDTO.startDate` | **NEW** |
| `endDate` | `String?` | Yes | `UserCompletedReadingActivityDTO.endDate` | **NEW** |
| `bookTitle` | `String?` | Yes | `UserCompletedReadingActivityDTO.bookTitle` | **NEW** |
| `bookCoverUrl` | `String?` | Yes | `UserCompletedReadingActivityDTO.bookCoverUrl` | **NEW** |

## Validation Rules

1. All enriched fields are **nullable** — backend returns `null` when Google Books API is unreachable or data unavailable.
2. Base fields (`id`, `createdAt`, `type`, `clubId`, `userId`, `meetingId`, `readingGoalId`, `bookId` on concrete types) remain **non-nullable**.
3. `Activity.fromJson` polymorphic dispatch is unchanged — it switches on the `type` field.
4. After model changes, run `dart run build_runner build --delete-conflicting-outputs` to regenerate `.g.dart` files.

## State Transitions

N/A — Activity entities are immutable DTOs deserialized from JSON. No state transitions.
