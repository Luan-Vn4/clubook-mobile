# Feature Specification: Club Activities Feed

**Feature Branch**: `feat/activities`

**Created**: 2026-06-08

**Status**: Draft

**Input**: User description: "Implement club activities posts visible in the club page and home menu. Activities are events that happen in the club like someone completing a reading goal, the club defining a new reading goal, or a meeting being scheduled."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - View All Activities on Club Page (Priority: P1)

As a club member, I want to see a feed of all recent activities when I open a club's profile page, so that I can stay informed about what is happening in the club.

**Why this priority**: The activity feed is the core value of this feature. Without it, the other views (filtered tabs, homepage section) have no data to display.

**Independent Test**: Can be fully tested by navigating to any club's profile page and verifying that mixed activity cards appear in a scrollable list. Delivers immediate value by showing club events.

**Acceptance Scenarios**:

1. **Given** a user is a member of a club with recent activities, **When** they navigate to the club's profile page, **Then** they see an "Atividades" tab selected by default and a scrollable list of activity cards showing all activity types (reading completed, reading goal defined, meeting defined) ordered from newest to oldest.
2. **Given** a club has no activities, **When** the user views the club page activities tab, **Then** they see an empty state indicating no activities yet.
3. **Given** the user is viewing the activities list, **When** they scroll down, **Then** more activities load progressively (pagination).

---

### User Story 2 - Filter Activities by Type on Club Page (Priority: P2)

As a club member, I want to filter activities by type using tabs, so that I can focus on specific kinds of events (readings, meetings, or all).

**Why this priority**: Filtering enhances navigation but depends on the base activity feed (P1) being functional first.

**Independent Test**: Can be tested by selecting each of the three filter tabs on the club page and verifying the correct activity subset is displayed.

**Acceptance Scenarios**:

1. **Given** the user is on the club page activities tab, **When** they tap the "Leituras" filter tab, **Then** only reading-related activities appear (reading goal defined and reading completed).
2. **Given** the user is on the club page activities tab, **When** they tap the "Encontros" filter tab, **Then** only meeting-defined activities appear.
3. **Given** the user is on a filtered view ("Leituras" or "Encontros"), **When** they tap "Atividades" tab, **Then** all activity types are shown again.
4. **Given** the user switches between filter tabs, **When** the selected tab changes, **Then** the active tab is visually highlighted with the secondary color background and white text, while inactive tabs show the darkwhite background with black text.

---

### User Story 3 - View Activities on Homepage (Priority: P3)

As a user, I want to see recent activities from all my clubs on the homepage, so that I can quickly see what is happening across all my clubs without navigating to each one individually.

**Why this priority**: Homepage integration extends the feature's reach but depends on P1 for the activity data and card rendering. This is a separate surface that adds significant daily engagement value.

**Independent Test**: Can be tested by navigating to the homepage and verifying that activity cards appear in the "Atividades" section, each with a club header identifying the source club.

**Acceptance Scenarios**:

1. **Given** the user is a member of multiple clubs with recent activities, **When** they open the homepage, **Then** they see an "Atividades" section below the "Recentes" clubs carousel showing activity cards from all their clubs.
2. **Given** the user is viewing the homepage activities section, **When** they look at an activity card, **Then** each card displays a header bar with the source club's photo, club name, and activity creation date.
3. **Given** the user has no activities across any club, **When** they view the homepage, **Then** the "Atividades" section shows an appropriate empty state or is hidden.

---

### Edge Cases

- What happens when an activity references a book or user with missing data (e.g., deleted book, removed member)? The card should gracefully handle missing data by showing placeholder text or a fallback image.
- What happens when the network is slow or unavailable while loading activities? A loading indicator should be shown during fetch, and a retry option should appear on failure.
- What happens when the user rapidly switches between filter tabs? The system should debounce or cancel in-flight requests to avoid showing stale data.
- What happens when the backend returns an unknown activity type? The system should skip it (not render a card) and log the unrecognized type for developer awareness.

## Clarifications

### Session 2026-06-08

- Q: The Activities API returns only reference IDs but cards need display data. How should display data be obtained? → A: Client resolves each reference by calling other existing API endpoints (meeting details, user profile, book details, reading goal details, club details).
- Q: Should the "Leituras" filter tab include both reading goal defined AND member completed reading, or only reading goals? → A: Show both types (reading goal defined + member completed reading).
- Q: How should the UI handle unknown/future activity types from the API? → A: Skip unknown types entirely (don't render), but log them for debugging purposes.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST display activity cards on the club profile page, each representing a club event (reading completed, reading goal defined, or meeting defined).
- **FR-002**: Each activity card MUST show the activity type title, contextual information (book name, date range, location, or user info depending on type), and a book cover image.
- **FR-003**: Reading completed activity cards MUST display the activity title "Atividade: Leitura Concluída", the book name, the completing member's avatar and name, the reading date range, and the book cover image.
- **FR-004**: Reading goal defined activity cards MUST display the activity title "Atividade: Meta de Leitura", the book name with a book icon, the goal date range with a calendar icon, and the book cover image.
- **FR-005**: Meeting defined activity cards MUST display the activity title "Atividade: Encontro Definido", the meeting location with a location icon, the associated book name with a book icon, and the book cover image.
- **FR-006**: The club page MUST display three filter tabs: "Atividades" (all), "Leituras" (reading-related), and "Encontros" (meeting-related).
- **FR-007**: The selected filter tab MUST be visually distinguished using the secondary color (#5966b1) background with white text; unselected tabs MUST use the darkwhite (#cfcfcf) background with black text.
- **FR-008**: The "Atividades" tab MUST be selected by default when the club page loads.
- **FR-009**: Activity cards displayed on the club page MUST NOT show a club header (the user is already inside the club context).
- **FR-010**: Activity cards displayed on the homepage MUST show a club header containing the source club's photo, club name, and activity creation date.
- **FR-011**: The club header on homepage cards MUST use the secondary color (#5966b1) as background with white text.
- **FR-012**: The homepage MUST display an "Atividades" section with a named section header (matching the "Recentes" section style) below the clubs carousel.
- **FR-013**: The system MUST load activities progressively with pagination to handle large activity lists.
- **FR-014**: Activity lists MUST have a 12px vertical gap between cards.
- **FR-015**: Each card MUST have 12px internal padding, 8px border radius, and a white (#f5f5f5) background.
- **FR-016**: Activity titles MUST use the Navicula Medium font at 16px in violeta (#2f3491) color.
- **FR-017**: Activity detail text (book names, dates, locations, user names) MUST use the Inter Medium font at 12px in black (#494949) color.
- **FR-018**: The system MUST resolve activity reference IDs into display data by fetching details from related API endpoints (e.g., meeting details for location/book, user profile for avatar/name, book details for name/cover, reading goal details for date range, club details for photo/name).
- **FR-019**: Reference data resolution MUST be batched or parallelized where possible to avoid N+1 request patterns when loading multiple activity cards.
- **FR-020**: The system MUST skip activity types it does not recognize (do not render unknown types in the feed), but MUST log the unrecognized `type` value for debugging purposes.

### Key Entities

- **Activity**: Base entity representing any club event. Has a type, creation date, and associated club.
- **ClubActivity**: A club-scoped activity with one of three subtypes:
  - **MemberCompletedReadingActivity**: A member completed reading a book. Contains reference IDs (`userId`, `bookId`). The client resolves user info (avatar, name) and book info (name, cover) via separate API calls. Date range comes from the reading goal or book-user relation.
  - **ReadingGoalDefinedActivity**: A new reading goal was set for the club. Contains reference ID (`readingGoalId`). The client resolves reading goal details (associated book, date range) and book info (name, cover) via separate API calls.
  - **MeetingDefinedActivity**: A new meeting was scheduled. Contains reference ID (`meetingId`). The client resolves meeting details (location, associated book) and book info (name, cover) via separate API calls.
- **ActivityFilter**: An enumeration of filter options for the club page tabs: "all" (Atividades), "readings" (Leituras), "meetings" (Encontros).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can view activities on the club page within 2 seconds of navigating to the club profile.
- **SC-002**: Users can switch between filter tabs and see filtered results update within 1 second.
- **SC-003**: Activity cards accurately display all information for each of the three activity types without truncation or visual overflow.
- **SC-004**: The homepage activities section loads alongside the clubs carousel without blocking page interaction.
- **SC-005**: Users can scroll through 50+ activities without noticeable lag or frame drops.

## Assumptions

- The backend API provides endpoints for fetching activities with reference IDs, and separate endpoints exist for resolving referenced entities (meetings, users, books, reading goals, clubs).
- The existing domain models (`MemberCompletedReadingActivity`, `ReadingGoalDefinedActivity`, `MeetingDefinedActivity`) contain reference IDs; the client is responsible for resolving them into display data.
- Activity data is fetched from the server on demand (not cached locally), and the existing activities repository handles pagination.
- The homepage exists or will be created as part of this feature, with the "Recentes" carousel already implemented.
- Book cover images and member avatars are served as URLs from the backend (no local asset management needed).
- Filter tabs on the club page filter on the client side after fetching all activities (the club activity endpoint has no type filter parameter).
