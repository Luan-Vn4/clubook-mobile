# Research: Club Activities Feed

**Branch**: `feat/activities` | **Date**: 2026-06-08

## Research Tasks

### R-1: How to map enriched DTO fields into existing domain models?

**Decision**: Add nullable fields to existing concrete activity classes. All enriched fields from the backend are nullable (per updated manual), so this is a backward-compatible change.

**Rationale**:
- The existing `@JsonSerializable` pattern with `build_runner` handles nullable fields automatically.
- No new classes needed — the type hierarchy (`Activity` → `ClubActivity`/`UserActivity` → concrete types) remains valid.
- `ClubActivity` abstract class gains `clubName` and `clubPhotoUrl` since these are shared across all club activity types.
- Concrete types gain their specific enriched fields.

**Alternatives considered**:
- Separate "enriched" vs "reference" models → rejected (unnecessary duplication, violates YAGNI)
- Flat map approach (`Map<String, dynamic>`) → rejected (loses type safety)

### R-2: How to pass server-side type filter to API calls?

**Decision**: Add optional `List<ActivityType>? types` parameter to repository methods. When non-null, convert each enum value to its `@JsonValue` string and append as repeated `type` query parameters.

**Rationale**:
- The backend accepts repeated `?type=MEETING_DEFINED&type=READING_GOAL_DEFINED` params.
- The existing `ActivityType` enum already has `@JsonValue` annotations (e.g., `@JsonValue('MEETING_DEFINED')`).
- `ActivityType` can leverage the generated `_$ActivityTypeEnumMap` to convert enum → string for query params.
- When `types` is null or empty, no `type` param is sent (returns all types).

**Alternatives considered**:
- String-based filter params → rejected (loses type safety, enum already exists)
- Client-side filtering → rejected (backend now supports it natively)

### R-3: How to refactor card widgets to use enriched data?

**Decision**: Remove `AsyncBuilder` and multi-fetch `_getDependencies()` methods. Card widgets read enriched fields directly from activity entities. The `ClubActivityCardWidget` base widget signature changes from requiring `Club` + `BookItem` objects to accepting nullable `String?` fields for display data (clubName, clubPhotoUrl, bookTitle, bookCoverUrl).

**Rationale**:
- All display data is now embedded in the activity DTO — no additional API calls needed.
- Removing `AsyncBuilder` eliminates loading/error states that were only needed for multi-fetch resolution.
- The `Club` and `BookItem` domain objects were only used to extract display strings and URLs — now provided directly.
- Nullable fields handle the case where backend enrichment returns null (e.g., Google Books API unreachable).

**Alternatives considered**:
- Keep `AsyncBuilder` with nullable fallback → rejected (adds complexity for no benefit)
- Create new DTO classes for card display → rejected (violates YAGNI, domain models suffice)

### R-4: How does the home feed endpoint change?

**Decision**: The `findActivitiesForUser` method currently passes `userId` as a query parameter. The updated backend (`GET /api/v1/activities`) uses the auth token and accepts no `userId` param. The method must be updated to remove the `userId` query parameter and only pass `page`, `size`, and optional `type`.

**Rationale**:
- The updated manual confirms `GET /api/v1/activities` has no `userId` parameter — it derives the user from the auth token.
- Current code in `activities_repository.dart` passes `'userId': userId` which is incorrect per the new API.
- Response type is `PagedModel<ActivityDTO>` which the existing `Page<Activity>.fromJson` already handles.

**Alternatives considered**:
- Keep `userId` param for backward compatibility → rejected (the backend no longer accepts it)

### R-5: How to handle the DTO type hierarchy in deserialization?

**Decision**: No change needed. The existing `Activity.fromJson` factory already dispatches based on the `type` field to the correct concrete `fromJson` constructor. The new enriched fields are simply additional nullable fields in those constructors — `json_serializable` handles them automatically after `build_runner` regeneration.

**Rationale**:
- The polymorphic discrimination pattern (switch on `type`) is already implemented and correct.
- Adding fields to `@JsonSerializable` classes is a non-breaking change.
- `build_runner` will regenerate `.g.dart` files with the new fields included.

**Alternatives considered**:
- Manual `fromJson`/`toJson` for enriched fields → rejected (json_serializable already handles this)
