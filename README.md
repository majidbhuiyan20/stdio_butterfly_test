# Code Review: SMS Console Starter

## Overview
The starter code in `lib/sms_console.dart` provides a basic functional prototype but contains several critical flaws that make it unsuitable for production. Below are the key findings and the architectural strategy used to resolve them.

---

## 🏗 Architecture Selection: Clean Architecture (Layered)

### Which architecture is used?
I have implemented a **Clean Architecture** (Layered) pattern, organized into three distinct layers:
1.  **Domain Layer**: Contains pure business logic, entities, and repository interfaces. It is independent of any external libraries or the Flutter framework.
2.  **Data Layer**: Handles data retrieval from the API, mapping JSON to domain entities, and implementing the repository interfaces.
3.  **Presentation Layer**: Manages the UI and state using **Riverpod**.

### Why use this architecture?
-   **Separation of Concerns**: By isolating business logic (like decimal money arithmetic) from the UI, the code becomes easier to maintain and less prone to side-effect bugs.
-   **Testability**: The domain layer can be unit-tested without mocking the entire Flutter framework. We can "prove" the money logic is correct via pure Dart tests.
-   **Multi-Platform Ready**: Since the business logic is decoupled from the UI, adapting the app for Desktop and Web (as required in Part 4) only requires changes to the presentation layer.
-   **Multi-Tenant Security**: Centralizing API logic in the data layer ensures that mandatory headers (`X-Tenant-Id`) are never missed, preventing data leaks.

### State Management: Riverpod
I chose **Riverpod** for the following reasons:
-   **Compile-time Safety**: Eliminates common provider-related errors.
-   **Lifecycle Management**: Automatically handles disposal of state, solving the "setState after await" crash identified in the review.
-   **Global State**: Easily manages state across the app without dependency on the `BuildContext`.

---

## Findings & Defects

### 1. Hardcoded Secrets (Security)
- **Severity**: Critical
- **Location**: Line 10
- **What's wrong**: The production API key (`kApiKey`) is hardcoded in the source. This leads to credential leakage if the code is committed to version control.
- **How to fix**: Use a configuration injection system (like `--dart-define` or `.env` files) to provide secrets at build time.

### 2. Missing Mandatory Headers (Functional)
- **Severity**: Critical
- **Location**: Lines 53, 76, 126
- **What's wrong**: The `API-CONTRACT.md` requires an `X-Tenant-Id` header for every call. The code never sends it.
- **How to fix**: Centralize request logic in an `ApiClient` that automatically appends all required headers (Auth and Tenancy).

### 3. Floating Point Inaccuracy (Financial)
- **Severity**: High
- **Location**: Lines 14, 21, 61, 89
- **What's wrong**: The code uses `double` for currency and rates. Binary floating-point arithmetic (e.g., `0.075 * 2`) is imprecise and leads to cumulative rounding errors.
- **How to fix**: Use the `decimal` package or represent money in minor units (integers) to ensure exact arithmetic.

### 4. Inventing UI Data (Data Integrity)
- **Severity**: High
- **Location**: Line 140
- **What's wrong**: The UI attempts to display `rows[i]['recipient']` in the cost breakdown list. However, the API contract explicitly states the cost breakdown endpoint *never* returns recipient numbers.
- **How to fix**: Align the UI models strictly with the API contract. Remove the recipient display from the cost summary.

### 5. Local Calculation of Source of Truth (Integrity)
- **Severity**: High
- **Location**: Lines 86-89
- **What's wrong**: The code calculates the cost of a sent SMS locally using `rateFor(provider) * segments`. It ignores the `cost` and `segmentCount` returned by the server.
- **How to fix**: Always use the response from the API as the source of truth for billing and status.

### 6. State Modification After Async Await (Stability)
- **Severity**: Medium
- **Location**: Lines 52, 102
- **What's wrong**: `setState` is called after an `await` without checking `if (!mounted)`. If a user navigates away before the request finishes, the app will throw an exception.
- **How to fix**: Use a state management solution (like Riverpod) that survives widget lifecycle or add `if (!mounted) return;` before `setState`.

### 7. Inefficient Re-fetching (Performance)
- **Severity**: Medium
- **Location**: Lines 122-146
- **What's wrong**: A `FutureBuilder` is placed inside the `build` method. This triggers a network request every time the widget rebuilds (e.g., on keyboard toggle or parent update).
- **How to fix**: Store the Future in a state variable or use a `FutureProvider` in Riverpod to cache the result.

### 8. Silent Failures (UX)
- **Severity**: Medium
- **Location**: Lines 99-101
- **What's wrong**: Exceptions are caught and stored in `AppState.lastError`, but the UI never informs the user that an error occurred. The loading spinner just stops.
- **How to fix**: Implement a proper Error state in the UI and show a `SnackBar` or error dialog when requests fail.
