# Activities API — Reference Manual

**Branch**: `feat/activities` | **Updated**: 2026-06-08

---

## Overview

The Activities API provides three endpoints for querying activity feeds. Activities are classified by type and grouped into two categories:

- **Club Activities** — events within a club (meetings, reading goals, completed readings)
- **User Activities** — personal user events (completed readings)

All endpoints support **paginated responses** and optional **type filtering** via the `type` query parameter.

---

## Endpoints

### 1. User Home Feed

```
GET /api/v1/activities
```

Returns activities from all clubs the authenticated user is a member of. Returns **only ClubActivity** instances (UserActivity is excluded from the home feed).

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `page` | int | No | Page number (default: 0) |
| `size` | int | No | Page size (default: 20, max: 50) |
| `type` | `ActivityType[]` | No | Filter by activity types (repeated param) |

**Example:**

```bash
# All activities
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8080/api/v1/activities?page=0&size=10"

# Filtered to meetings only
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8080/api/v1/activities?type=MEETING_DEFINED&page=0&size=10"

# Filtered to multiple types
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8080/api/v1/activities?type=MEETING_DEFINED&type=READING_GOAL_DEFINED"
```

**Response:** `PagedModel<ActivityDTO>`

---

### 2. Club Activity Feed

```
GET /api/v1/clubs/{clubId}/activities
```

Returns all activities for a specific club.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `clubId` | UUID | Yes | Path parameter — club identifier |
| `page` | int | No | Page number (default: 0) |
| `size` | int | No | Page size (default: 20, max: 50) |
| `type` | `ActivityType[]` | No | Filter by activity types (repeated param) |

**Example:**

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8080/api/v1/clubs/$CLUB_ID/activities?type=MEMBER_COMPLETED_READING&page=0&size=10"
```

**Response:** `PagedModel<ClubActivityDTO>`

---

### 3. User Activity Feed

```
GET /api/v1/users/{userId}/activities
```

Returns all personal activities for a specific user.

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `userId` | UUID | Yes | Path parameter — user identifier |
| `page` | int | No | Page number (default: 0) |
| `size` | int | No | Page size (default: 20, max: 50) |
| `type` | `ActivityType[]` | No | Filter by activity types (repeated param) |

**Example:**

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8080/api/v1/users/$USER_ID/activities?type=USER_COMPLETED_READING&page=0&size=10"
```

**Response:** `PagedModel<UserActivityDTO>`

---

## Type Filter

### ActivityType Enum

The `type` query parameter accepts values from the `ActivityType` enum:

| Value | Category | Description |
|-------|----------|-------------|
| `MEETING_DEFINED` | ClubActivity | A meeting was scheduled |
| `MEMBER_COMPLETED_READING` | ClubActivity | A club member finished reading a book |
| `READING_GOAL_DEFINED` | ClubActivity | A reading goal was set for the club |
| `USER_COMPLETED_READING` | UserActivity | A user finished reading a book |

### Filtering Rules

- **Omit `type`** → returns all activity types
- **Single type** → `?type=MEETING_DEFINED`
- **Multiple types** → `?type=MEETING_DEFINED&type=READING_GOAL_DEFINED` (repeated parameter)
- **Invalid type** → `400 Bad Request` (Spring validates against enum values automatically)
- **Cross-category filter** — passing `USER_COMPLETED_READING` to the club or home feed returns an empty page (valid but no results)

---

## Response DTOs

### Type Hierarchy

```
ActivityDTO
├── ClubActivityDTO
│   ├── MeetingDefinedActivityDTO
│   ├── MemberCompletedReadingActivityDTO
│   └── ReadingGoalDefinedActivityDTO
└── UserActivityDTO
    └── UserCompletedReadingActivityDTO
```

### ActivityDTO (base interface)

Common fields present in **all** activity responses:

| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Unique activity identifier |
| `createdAt` | LocalDateTime | Timestamp of activity creation |
| `type` | ActivityType | Activity type enum value |

### ClubActivityDTO (extends ActivityDTO)

Additional fields for all club-scoped activities:

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `clubId` | UUID | No | Club identifier |
| `clubName` | String | Yes | Display name of the club |
| `clubPhotoUrl` | String | Yes | URL of the club's profile image |

### UserActivityDTO (extends ActivityDTO)

Additional fields for all user-scoped activities:

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `userId` | UUID | No | User identifier |

---

### MeetingDefinedActivityDTO

```json
{
  "type": "MEETING_DEFINED",
  "id": "uuid",
  "createdAt": "2026-06-08T10:00:00",
  "clubId": "uuid",
  "meetingId": "uuid",
  "clubName": "Book Lovers Club",
  "clubPhotoUrl": "https://...",
  "meetingAddress": "Rua das Flores, 123",
  "meetingDate": "2026-06-15",
  "bookId": "google-books-volume-id",
  "bookTitle": "The Great Gatsby",
  "bookCoverUrl": "https://..."
}
```

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `meetingId` | UUID | No | Meeting identifier |
| `clubName` | String | Yes | Club display name |
| `clubPhotoUrl` | String | Yes | Club profile image URL |
| `meetingAddress` | String | Yes | Meeting location address |
| `meetingDate` | LocalDate | Yes | Date of the meeting (from reading goal start date) |
| `bookId` | String | Yes | Google Books volume ID |
| `bookTitle` | String | Yes | Book title (from Google Books API) |
| `bookCoverUrl` | String | Yes | Book cover image URL (from Google Books API) |

---

### MemberCompletedReadingActivityDTO

```json
{
  "type": "MEMBER_COMPLETED_READING",
  "id": "uuid",
  "createdAt": "2026-06-08T14:30:00",
  "clubId": "uuid",
  "userId": "uuid",
  "bookId": "google-books-volume-id",
  "startDate": "2026-05-01",
  "endDate": "2026-06-01",
  "clubName": "Book Lovers Club",
  "clubPhotoUrl": "https://...",
  "userName": "João Silva",
  "userAvatarUrl": "https://...",
  "bookTitle": "Dom Casmurro",
  "bookCoverUrl": "https://..."
}
```

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `userId` | UUID | No | User who completed the reading |
| `bookId` | String | No | Google Books volume ID |
| `startDate` | LocalDate | Yes | Reading goal start date (null if no reading goal) |
| `endDate` | LocalDate | Yes | Reading goal end date (null if no reading goal) |
| `clubName` | String | Yes | Club display name |
| `clubPhotoUrl` | String | Yes | Club profile image URL |
| `userName` | String | Yes | Full name of the user |
| `userAvatarUrl` | String | Yes | User profile image URL |
| `bookTitle` | String | Yes | Book title (from Google Books API) |
| `bookCoverUrl` | String | Yes | Book cover image URL (from Google Books API) |

---

### ReadingGoalDefinedActivityDTO

```json
{
  "type": "READING_GOAL_DEFINED",
  "id": "uuid",
  "createdAt": "2026-06-08T09:00:00",
  "clubId": "uuid",
  "readingGoalId": "uuid",
  "clubName": "Book Lovers Club",
  "clubPhotoUrl": "https://...",
  "goalStartDate": "2026-06-01",
  "goalEndDate": "2026-07-01",
  "bookTitle": "1984",
  "bookCoverUrl": "https://..."
}
```

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `readingGoalId` | UUID | No | Reading goal identifier |
| `clubName` | String | Yes | Club display name |
| `clubPhotoUrl` | String | Yes | Club profile image URL |
| `goalStartDate` | LocalDate | Yes | Reading goal start date |
| `goalEndDate` | LocalDate | Yes | Reading goal end date |
| `bookTitle` | String | Yes | Book title (from Google Books API) |
| `bookCoverUrl` | String | Yes | Book cover image URL (from Google Books API) |

---

### UserCompletedReadingActivityDTO

```json
{
  "type": "USER_COMPLETED_READING",
  "id": "uuid",
  "createdAt": "2026-06-08T16:00:00",
  "userId": "uuid",
  "bookId": "google-books-volume-id",
  "startDate": null,
  "endDate": null,
  "bookTitle": "Sapiens",
  "bookCoverUrl": "https://..."
}
```

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `userId` | UUID | No | User identifier |
| `bookId` | String | No | Google Books volume ID |
| `startDate` | LocalDate | Yes | Always null for user activities (no club reading goal context) |
| `endDate` | LocalDate | Yes | Always null for user activities (no club reading goal context) |
| `bookTitle` | String | Yes | Book title (from Google Books API) |
| `bookCoverUrl` | String | Yes | Book cover image URL (from Google Books API) |

---

## Pagination

All endpoints return paginated responses using Spring Data's `PagedModel`. The response includes:

```json
{
  "content": [...],
  "page": {
    "number": 0,
    "size": 10,
    "totalElements": 42,
    "totalPages": 5
  }
}
```

| Parameter | Default | Max |
|-----------|---------|-----|
| `page` | 0 | — |
| `size` | 20 | 50 |

---

## Error Handling

| Status | Condition |
|--------|-----------|
| `400 Bad Request` | Invalid `ActivityType` value in `type` parameter |
| `401 Unauthorized` | Missing or invalid authentication token |
| `500 Internal Server Error` | Never caused by Google Books API failures — enrichment fields return `null` gracefully |

---

## Design Decisions

### UserActivity Exclusion from Home Feed

`GET /api/v1/activities` returns **only `ClubActivity`** instances. `UserActivity` (e.g., `USER_COMPLETED_READING`) is accessible exclusively via `GET /api/v1/users/{userId}/activities`. This is a deliberate scope decision — the home feed shows social/club activity, while personal activity history lives in the user profile.

### Null Safety on Enriched Fields

All enriched fields (`clubName`, `bookTitle`, `bookCoverUrl`, etc.) are nullable:
- **Club/user fields** — populated from JPA relationships (always available when the entity exists)
- **Book fields** — populated from Google Books API; `null` if the API is unreachable or the book is not found
- **Date fields** — `startDate`/`endDate` on `MemberCompletedReadingActivity` are populated from the associated `ReadingGoal`; `null` when no reading goal exists

### Enum-Based Type Filtering

The `type` parameter uses Spring's native enum binding. Invalid values are rejected at the controller layer with a `400 Bad Request` — no string parsing or manual validation in the service layer.

### Database-Level Pagination

All queries use database-level pagination (`Pageable` with JPQL). The home feed uses a single subquery joining clubs to activities — no in-memory sort or N+1 queries.