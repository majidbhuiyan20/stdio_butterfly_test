# AI Usage Report

## Generation Strategy
I used this AI assistant as a "pair programmer" to accelerate the migration to Clean Architecture.
- **Scaffolding**: The AI generated the initial folder structure and boilerplate for the Domain and Data layers based on the `API-CONTRACT.md`.
- **Refactoring**: I provided the AI with the identified bugs from `sms_console.dart`, and it helped rewrite the logic using Riverpod and the `decimal` package.
- **Styling**: The AI suggested the "Premium" design for the custom Snackbar and the Responsive layout breakpoints.

## Where the AI was wrong
1. **Flutter Version/API Inconsistency**: The AI initially suggested using `CardTheme` inside `ThemeData`, but the current Flutter SDK requires `CardThemeData`. This led to a build failure that I had to fix by correcting the type.
2. **Snackbar Stacking**: The initial implementation suggested by the AI simply called `showSnackBar`, which led to "queueing" behavior where multiple clicks caused snackbars to persist for a long time. I had to explicitly instruct it to use `clearSnackBars()` to achieve the requested "non-stacking" behavior.
3. **E.164 Validation**: The initial validation logic for phone numbers was too loose. I replaced it with a stricter Regex (`r'^\+[1-9]\d{1,14}$'`) to ensure compliance with the API contract.

## What I wrote myself
- **Dependency Management**: I manually verified and added the specific versions for `decimal`, `flutter_riverpod`, and `flutter_dotenv` to ensure package compatibility.
- **Incident Response History**: I manually purged the `.env` file from the Git history using `filter-branch` after the AI accidentally staged it during a bulk commit suggestion. I did not trust the agent to handle the `git force push` without manual oversight.
- **Business Logic Guardrails**: I manually added the `if (previous?.error != next.error)` check in the `ref.listen` block to prevent duplicate snackbar triggers during state rebuilds.
