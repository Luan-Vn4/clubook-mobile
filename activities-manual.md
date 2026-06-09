# Activities API Manual

## Overview

The Activities API is a **read-only** feed of platform events (meetings scheduled, readings completed, goals defined). Activities are **system-generated** — they are not created or modified by clients. They appear automatically when backing events occur (e.g. a meeting is created, a user finishes a book, a club sets a reading goal).

**Base URL**: `/api/v1`

**Authentication**: All endpoints require a valid JWT Bearer token issued by the Keycloak OAuth2 resource server.

```
Authorization: Bearer <token>
```

Unauthenticated requests receive **401 Unauthorized**.

---

## Endpoints

### 1. Get Activities for Logged User

Returns a polymorphic feed of activities relevant to the currently authenticated user — specifically, activities from all clubs the user is a member of.

```
GET /api/v1/activities
```

| Query Parameter | Type   | Default | Description                        |
|-----------------|--------|---------|------------------------------------|
| `page`          | int    | 0       | Zero-based page index              |
| `size`          | int    | 20      | Number of items per page           |
| `sort`          | string | unset   | Sort expression (e.g. `createdAt,desc`) |

**Response**: `200 OK` — `PagedModel<ActivityDTO>` (polymorphic — see [Response Schemas](#response-schemas))

---

### 2. Get Activities for a Club

Returns all activities associated with a specific club.

```
GET /api/v1/clubs/{clubId}/activity
```

| Parameter        | Location | Type | Required | Description        |
|------------------|----------|------|----------|--------------------|
| `clubId`         | path     | UUID | Yes      | ID of the club     |

| Query Parameter | Type   | Default | Description                        |
|-----------------|--------|---------|------------------------------------|
| `page`          | int    | 0       | Zero-based page index              |
| `size`          | int    | 20      | Number of items per page           |
| `sort`          | string | unset   | Sort expression                    |

**Response**: `200 OK` — `PagedModel<ClubActivityDTO>` (polymorphic — see [Response Schemas](#response-schemas))

---

### 3. Get Activities for a User

Returns all activities associated with a specific user.

```
GET /api/v1/users/{userId}/activities
```

| Parameter        | Location | Type | Required | Description        |
|------------------|----------|------|----------|--------------------|
| `userId`         | path     | UUID | Yes      | ID of the user     |

| Query Parameter | Type   | Default | Description                        |
|-----------------|--------|---------|------------------------------------|
| `page`          | int    | 0       | Zero-based page index              |
| `size`          | int    | 20      | Number of items per page           |
| `sort`          | string | unset   | Sort expression                    |

**Response**: `200 OK` — `PagedModel<UserActivityDTO>` (polymorphic — see [Response Schemas](#response-schemas))

---

## Response Schemas

### Pagination Envelope (`PagedModel<T>`)

All endpoints return a Spring Data `PagedModel` wrapper:

| Field          | Type    | Description                          |
|----------------|---------|--------------------------------------|
| `content`      | T[]     | Array of activity items on this page |
| `page.number`  | int     | Current page number (zero-based)     |
| `page.size`    | int     | Requested page size                  |
| `page.totalElements` | long | Total number of elements across all pages |
| `page.totalPages`    | int  | Total number of pages                |

---

### Polymorphic Discrimination

Activity responses are **polymorphic**. The `type` field acts as the discriminator. Parse `type` first, then deserialize into the concrete shape.

**`ActivityDTO`** — base fields present in **every** activity:

| Field       | Type          | Description                            |
|-------------|---------------|----------------------------------------|
| `id`        | UUID          | Unique activity identifier             |
| `createdAt` | LocalDateTime | ISO-8601 timestamp of when the activity was created |
| `type`      | String        | Discriminator — determines the payload shape |

---

### Concrete Activity Types

#### `MEETING_DEFINED` — Club Activity

A meeting was scheduled in a club.

| Field       | Type          | Description                  |
|-------------|---------------|------------------------------|
| `id`        | UUID          | Activity ID                  |
| `createdAt` | LocalDateTime | When the activity was created |
| `type`      | `"MEETING_DEFINED"` | Discriminator          |
| `clubId`    | UUID          | The club this meeting belongs to |
| `meetingId` | UUID          | The scheduled meeting's ID   |

#### `MEMBER_COMPLETED_READING` — Club Activity

A member of a club finished reading a book.

| Field       | Type          | Description                           |
|-------------|---------------|---------------------------------------|
| `id`        | UUID          | Activity ID                           |
| `createdAt` | LocalDateTime | When the activity was created         |
| `type`      | `"MEMBER_COMPLETED_READING"` | Discriminator               |
| `clubId`    | UUID          | The club the member belongs to        |
| `userId`    | UUID          | The user who completed the reading    |
| `bookId`    | String        | External book identifier (Google Books ID) |

#### `READING_GOAL_DEFINED` — Club Activity

A reading goal was set for a club.

| Field          | Type          | Description                    |
|----------------|---------------|--------------------------------|
| `id`           | UUID          | Activity ID                    |
| `createdAt`    | LocalDateTime | When the activity was created  |
| `type`         | `"READING_GOAL_DEFINED"` | Discriminator       |
| `clubId`       | UUID          | The club the goal belongs to   |
| `readingGoalId`| UUID          | The reading goal's ID          |

#### `USER_COMPLETED_READING` — User Activity

A user finished reading a book (outside any club context).

| Field       | Type          | Description                        |
|-------------|---------------|------------------------------------|
| `id`        | UUID          | Activity ID                        |
| `createdAt` | LocalDateTime | When the activity was created      |
| `type`      | `"USER_COMPLETED_READING"` | Discriminator          |
| `userId`    | UUID          | The user who completed the reading |
| `bookId`    | UUID          | Internal book-user relation ID     |

---

### Type Taxonomy

```
ActivityDTO (base)
├── ClubActivityDTO          (adds: clubId)
│   ├── MEETING_DEFINED      (adds: meetingId)
│   ├── MEMBER_COMPLETED_READING  (adds: userId, bookId)
│   └── READING_GOAL_DEFINED (adds: readingGoalId)
└── UserActivityDTO          (adds: userId)
    └── USER_COMPLETED_READING   (adds: bookId)
```

- **`GET /api/v1/activities`** → returns all types (base `ActivityDTO`).
- **`GET /api/v1/clubs/{clubId}/activity`** → returns only `ClubActivityDTO` subtypes (`MEETING_DEFINED`, `MEMBER_COMPLETED_READING`, `READING_GOAL_DEFINED`).
- **`GET /api/v1/users/{userId}/activities`** → returns only `UserActivityDTO` subtypes (`USER_COMPLETED_READING`).

---

## Error Responses

All errors follow a uniform schema:

| Field        | Type    | Description                             |
|--------------|---------|-----------------------------------------|
| `httpStatus` | int     | HTTP status code                        |
| `error`      | String  | Short error category label              |
| `message`    | String  | Detailed error description              |
| `timestamp`  | Instant | ISO-8601 UTC timestamp of the error     |

### Error Codes

| HTTP Status | When                                             |
|-------------|--------------------------------------------------|
| `401`       | Missing or invalid JWT token                     |
| `403`       | Token valid but user lacks permission            |
| `500`       | Internal server error (e.g. unmapped activity type) |

---

## Edge Cases & Implementation Notes

1. **Read-only resource** — There are no `POST`, `PUT`, `PATCH`, or `DELETE` endpoints. Activities are created automatically by the backend when underlying events occur (meeting creation, reading goal definition, reading completion).

2. **Logged-user feed is club-only** — `GET /api/v1/activities` currently aggregates activities only from clubs the user is a member of. User-level activities are **not** included in this endpoint (as of current implementation).

3. **In-memory pagination for user feed** — The logged-user activity feed loads all club activities into memory, sorts them, then slices for the requested page. Large datasets may cause latency or memory pressure. The backend has a TODO to replace this with a proper database-level query.

4. **Polymorphic deserialization** — Always read `type` first to determine the correct shape. Unknown `type` values should be gracefully handled (the backend may add new activity types in the future).

5. **Cascade deletes** — Deleting a meeting, reading goal, or book-user relation will cascade-delete the associated activity record. Activities reference their source entities by ID — if a source entity is deleted, the activity disappears.

6. **No custom page size cap** — The backend does not configure a maximum page size. Passing a very large `size` parameter could return an unbounded number of results.

7. **`bookId` type differs by context** — In `MEMBER_COMPLETED_READING`, `bookId` is a `String` (external Google Books ID). In `USER_COMPLETED_READING`, `bookId` is a `UUID` (internal book-user relation ID). This inconsistency is present in the current schema.

8. **Activity creation triggers** — Activities are published by:
   - **Meeting creation** → `MEETING_DEFINED`
   - **Reading goal definition** → `READING_GOAL_DEFINED`
   - **User completes reading a book** → `USER_COMPLETED_READING` (if not in a club) and/or `MEMBER_COMPLETED_READING` (if in a club)

---

## Swagger / OpenAPI

Interactive documentation is available at:

```
GET /swagger-ui/index.html
GET /v3/api-docs
```

These endpoints do not require authentication.