# API Contracts: Activities Endpoints

**Branch**: `feat/activities` | **Date**: 2026-06-08 | **Source**: `updated-manual.md`

## Endpoints

### 1. User Home Feed

```
GET /api/v1/activities
```

Returns activities from all clubs the authenticated user is a member of. Returns **only ClubActivity** instances.

**Auth**: Bearer token (required)

**Query Parameters:**

| Param | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `page` | `int` | No | 0 | Page number |
| `size` | `int` | No | 20 | Page size (max 50) |
| `type` | `ActivityType[]` | No | (all) | Repeated param for type filtering |

**Response**: `PagedModel<ActivityDTO>` → mapped to `Page<Activity>`

**Client Method**: `ActivitiesRepository.findActivitiesForUser(int pageSize, {List<ActivityType>? types})`

---

### 2. Club Activity Feed

```
GET /api/v1/clubs/{clubId}/activities
```

Returns all activities for a specific club.

**Auth**: Bearer token (required)

**Path Parameters:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `clubId` | `UUID` | Yes | Club identifier |

**Query Parameters:**

| Param | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `page` | `int` | No | 0 | Page number |
| `size` | `int` | No | 20 | Page size (max 50) |
| `type` | `ActivityType[]` | No | (all) | Repeated param for type filtering |

**Response**: `PagedModel<ClubActivityDTO>` → mapped to `Page<Activity>`

**Client Method**: `ActivitiesRepository.findActivitiesByClubId(String clubId, int pageSize, {List<ActivityType>? types})`

---

### 3. User Activity Feed

```
GET /api/v1/users/{userId}/activities
```

Returns all personal activities for a specific user.

**Auth**: Bearer token (required)

**Path Parameters:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `userId` | `UUID` | Yes | User identifier |

**Query Parameters:**

| Param | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `page` | `int` | No | 0 | Page number |
| `size` | `int` | No | 20 | Page size (max 50) |
| `type` | `ActivityType[]` | No | (all) | Repeated param for type filtering |

**Response**: `PagedModel<UserActivityDTO>` → mapped to `Page<Activity>`

**Client Method**: `ActivitiesRepository.findActivitiesByUserId(String userId, int pageSize, {List<ActivityType>? types})`

---

## Pagination Envelope

All endpoints return responses in this structure (maps to existing `Page<T>` / `PageInfo`):

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

## Type Filter Implementation

Type filter values are passed as repeated query parameters:

```dart
// Example: building type filter query params
if (types != null && types.isNotEmpty) {
  queryParams['type'] = types.map((t) => _enumToString(t)).toList();
}
```

The `ActivityType` enum values map as:

| Dart enum | Query param value |
|-----------|------------------|
| `ActivityType.meetingDefined` | `MEETING_DEFINED` |
| `ActivityType.memberCompletedReading` | `MEMBER_COMPLETED_READING` |
| `ActivityType.readingGoalDefined` | `READING_GOAL_DEFINED` |
| `ActivityType.userCompletedReading` | `USER_COMPLETED_READING` |

## Error Handling

| HTTP Status | Condition | Client Behavior |
|-------------|-----------|-----------------|
| 200 | Success | Parse and display activities |
| 400 | Invalid `ActivityType` value | Throw `Exception` with server message |
| 401 | Missing/invalid auth | Redirect to login (existing auth flow) |
| 500 | Server error | Throw `Exception` with generic message |

## Breaking Change from Old API

The home feed endpoint (`GET /api/v1/activities`) no longer accepts a `userId` query parameter. The current `findActivitiesForUser` method passes `userId` in query params — this must be removed.
