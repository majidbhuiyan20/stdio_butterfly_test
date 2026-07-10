# ADR 1: Architecture and State Management Selection

## Context
The project requires a robust, testable, and multi-platform solution for an SMS console. The starter code was tightly coupled, had hardcoded secrets, and lacked precision in financial calculations. As the sole engineer, I needed to pick a pattern that would scale to multiple platforms (Android, iOS, macOS, Web, Windows, Linux) while ensuring high data integrity for billing.

## Decision
I have chosen **Clean Architecture (Layered)** combined with **Riverpod** for state management.

### Architecture: Clean Architecture
- **Domain Layer**: Pure Dart logic, entities, and repository interfaces. This allows unit testing of money arithmetic without Flutter dependencies.
- **Data Layer**: Implementation of repositories, API clients, and data models. Centralizes security headers and JSON parsing.
- **Presentation Layer**: Riverpod providers and responsive widgets.

### State Management: Riverpod
- **Why Riverpod?**
    - **Compile-time safety**: Unlike `Provider`, it doesn't fail at runtime due to `ProviderNotFoundException`.
    - **No BuildContext dependency**: Allows logic to be easily tested and accessed outside the widget tree.
    - **Lifecycle awareness**: Automatically handles disposal of state, preventing the "setState after dispose" errors identified in the review.
    - **Provider Overrides**: Crucial for testing, allowing us to swap the real API repository with a Mock version in widget and golden tests.

## Alternatives Considered
- **BLoC**: Excellent for complex states, but potentially "boilerplate-heavy" for a single-screen project. Riverpod's `StateNotifier` and `FutureProvider` offered a more concise way to handle the same logic.
- **Vanilla setState**: Rejected due to tight coupling, difficulty in testing, and the specific memory leak/mounted issues found in the starter code.

## Consequences
- **Positive**: High test coverage of business logic, stable multi-tenant safety, and easy adaptation to desktop layouts.
- **Negative**: Slight increase in initial folder structure complexity compared to a single-file approach.
