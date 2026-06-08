<!--
Sync Impact Report
==================
Version change: 0.0.0 (template) → 1.0.0 (initial ratification)
Modified principles: N/A (initial creation)
Added sections:
  - Core Principles (I–V)
  - Technology Stack & Constraints
  - Development Workflow & Quality
  - Governance
Removed sections: N/A
Templates requiring updates:
  - .specify/templates/plan-template.md ✅ compatible (constitution check section present)
  - .specify/templates/spec-template.md ✅ compatible (requirements structure aligns)
  - .specify/templates/tasks-template.md ✅ compatible (phase/task structure aligns)
  - .specify/templates/commands/*.md ✅ no agent-specific references found
Follow-up TODOs: None
-->

# Booklub Constitution

## Core Principles

### I. Adapted MVVM Architecture

The project MUST follow an adapted MVVM (Model, View, View Model) pattern as
defined by the [Flutter app architecture guide](https://docs.flutter.dev/app-architecture/guide),
with modifications for clearer separation between domain logic and
infrastructure implementation.

The architecture comprises four top-level layers under `lib/`:

- **`ui/`** (UI Layer): Pages, widgets, layouts, and view models. View models
  manage view state and application logic (user actions, UI operations).
- **`domain/`** (Domain Layer): Business logic, domain models, and interface
  definitions for repositories and gateways. This layer owns the contracts.
- **`infra/`** (Infrastructure Layer): Concrete implementations of domain
  interfaces — repositories, gateways, and services. Responsible for data
  acquisition, transformation, caching, and external API communication.
- **`config/`** (Configuration Layer): Application-wide configuration including
  routing (`go_router`), themes, and environment settings.

Rationale: Strict layer boundaries enforce separation of concerns, improve
testability (domain can be tested without infrastructure), and enable
independent evolution of UI and data layers.

### II. Layer Dependency Discipline

Dependencies between layers MUST flow in a single direction:

- `ui` MAY depend on `domain` (models, repository interfaces) but MUST NOT
  depend on `infra`.
- `domain` MUST NOT depend on `ui` or `infra`. It defines interfaces only.
- `infra` depends on `domain` (implements its interfaces) but MUST NOT depend
  on `ui`.
- `config` MAY reference `ui` (for route targets) but MUST NOT contain
  business logic.
- `utils` is a shared utility layer with no business logic; all layers MAY
  reference it.

Cross-layer violations (e.g., importing an `infra` concrete class from `ui`)
MUST be flagged in code review and corrected before merge.

Rationale: Unidirectional dependency prevents circular coupling, keeps the
domain pure, and allows swapping infrastructure (e.g., changing from REST to
GraphQL) without touching UI code.

### III. Feature-Based UI Organization

UI code MUST be organized by feature following a Next.js-style directory
structure where each subdirectory represents a navigation path:

```
ui/
├── core/           → Shared widgets, layouts, view models
├── home/
│   ├── home_page.dart
│   ├── view_models/
│   └── widgets/
├── clubs/
│   ├── clubs_page.dart
│   ├── members/
│   │   ├── members_page.dart
│   │   ├── view_models/
│   │   └── widgets/
│   ├── view_models/
│   └── widgets/
└── <feature>/
    ├── <feature>_page.dart
    ├── view_models/
    └── widgets/
```

Rules:
- Each feature directory MUST contain its own `view_models/` and `widgets/`
  subdirectories.
- Widgets used across multiple features MUST reside in `ui/core/widgets/`.
- Pages MAY have related sub-pages (e.g., `clubs/members/`).
- View models MUST be scoped to their owning page; they MUST NOT directly
  reference view models from unrelated features.

Rationale: Feature-based colocation keeps related code together, reduces
navigation overhead, and scales naturally as the app grows.

### IV. Domain-First Interface Contracts

All data access contracts MUST be defined as abstract interfaces in the
`domain/` layer:

- `domain/<name>/repositories/` — abstract repository interfaces.
- `domain/<name>/gateways/` — abstract gateway interfaces.
- `domain/<name>/models/` — domain entity representations.
- `domain/<name>/use_cases/` — complex business logic (optional).

Concrete implementations reside in `infra/<name>/`:

- `infra/<name>/repositories/` — repository implementations.
- `infra/<name>/gateways/` — gateway implementations.
- `infra/<name>/services/` — service abstractions for complex access logic.

Use cases are optional and MUST only be created when at least one condition is
met:
1. Combines data from multiple repositories.
2. Encapsulates logic too complex for a single view model.
3. Will be reused by multiple view models.

Rationale: Domain-first design ensures business rules are not coupled to data
sources, enabling mock implementations for testing and infrastructure
independence.

### V. Simplicity & Incremental Growth

The project MUST follow YAGNI (You Aren't Gonna Need It) principles:

- Do not create use cases when view model logic suffices.
- Do not add abstraction layers until a concrete second consumer exists.
- Prefer the simplest solution that meets the current requirement.
- Services in `infra/` MUST only be extracted from repositories/gateways when
  the abstraction reduces verifiable complexity.

When in doubt, implement the straightforward approach first. Complexity MUST be
justified by a measurable need (performance, reuse, or testability), not by
speculation about future requirements.

Rationale: Premature abstraction is the primary source of technical debt in
growing applications. Enforcing simplicity keeps the codebase maintainable and
onboarding-friendly for a student development team.

## Technology Stack & Constraints

### Required Technologies

| Layer | Technology | Version Constraint |
|-------|-----------|-------------------|
| Framework | Flutter | SDK ≥ 3.7.2 |
| Language | Dart | ≥ 3.7.2 |
| State Management | Provider | ^6.1.4 |
| Navigation | go_router | ^15.1.1 |
| Networking | http | ^1.4.0 |
| Secure Storage | flutter_secure_storage | ^9.2.4 |
| Serialization | json_annotation | ^4.9.0 |
| Logging | logger | ^2.5.0 |
| i18n | intl | ^0.20.2 |

### Constraints

- All API communication MUST go through `infra/` layer repositories.
  The `ui` layer MUST NOT make direct HTTP calls.
- Sensitive data (tokens, credentials) MUST be stored via
  `flutter_secure_storage` — never in `SharedPreferences` or plain files.
- Navigation MUST be managed exclusively through `go_router` in
  `config/routing/`. Imperative `Navigator.push/pop` MUST NOT be used.
- State management MUST use `Provider` (or `ChangeNotifier` via Provider).
  No alternative state management libraries without constitution amendment.

### Prohibited Patterns

- Business logic in widget `build()` methods.
- Direct platform channel calls outside `infra/`.
- Hardcoded API URLs or secrets in source files.

## Development Workflow & Quality

### Code Organization

- New features MUST follow the directory structure defined in Principle III.
- Domain interfaces MUST be created before infrastructure implementations.
- The `test/` directory MUST mirror the `lib/` structure exactly.

### Code Review Gates

Before any merge to `main`:

1. **Architecture Compliance**: Verify layer dependency rules (Principle II).
2. **No Regressions**: All existing tests MUST pass.
3. **Interface Contracts**: New data access MUST define domain interfaces
   before implementation (Principle IV).
4. **No Prohibited Patterns**: Review for violations listed in Technology
   Stack constraints.

### Testing Standards

- Unit tests for view models and domain logic are REQUIRED.
- Widget tests for critical user flows are RECOMMENDED.
- Integration tests for repository implementations are RECOMMENDED.
- Test structure under `test/` MUST mirror `lib/` layout.

### Documentation

- Public APIs in `domain/` interfaces MUST include Dart doc comments.
- Complex view model logic MUST include inline comments explaining intent.
- Architecture decisions that deviate from this constitution MUST be documented
  in the project README or a dedicated ADR (Architecture Decision Record).

## Governance

This constitution is the authoritative governance document for the Booklub
mobile application project. It supersedes conflicting practices, ad-hoc
decisions, and informal conventions.

### Amendment Procedure

1. Any team member MAY propose an amendment.
2. The amendment MUST be documented with: rationale, affected principles,
   migration plan for existing code.
3. Amendments MUST be reviewed and approved by at least one project lead.
4. Upon approval, the constitution version MUST be incremented per semantic
   versioning rules and the `LAST_AMENDED_DATE` updated.

### Versioning Policy

- **MAJOR**: Principle removal, redefinition, or backward-incompatible
  governance changes.
- **MINOR**: New principle, section addition, or materially expanded guidance.
- **PATCH**: Clarifications, wording improvements, typo fixes.

### Compliance

- All pull requests MUST be checked against this constitution during review.
- Deviations from architectural principles MUST be justified in the PR
  description with a reference to the specific principle being relaxed.
- Persistent deviations (lasting more than one sprint) MUST trigger a
  constitution amendment proposal.

**Version**: 1.0.0 | **Ratified**: 2026-06-03 | **Last Amended**: 2026-06-03
