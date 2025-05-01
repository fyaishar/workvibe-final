---
description: 
globs: 
alwaysApply: true
---
Test-Driven Development (TDD) with flutter_test
Always write a failing test in the test/ directory before writing your implementation (Red-Green-Refactor). Use flutter_test for unit and widget tests, and packages like mockito or mocktail for mocking dependencies.
KISS (Keep It Simple, Stupid)
Favor the simplest widget, class, or function that fulfills the requirement. Resist premature abstraction in your UI and state-management layers.
DRY (Don’t Repeat Yourself)
Whenever you spot duplicated layout code or business logic, extract it into a reusable widget, service class, or helper function.
Standard Libraries & Community Packages
• Use Dart’s core libraries (e.g. dart:convert for JSON, dart:async for streams/futures).
• Leverage well-maintained pub packages—http or dio for network calls, intl for formatting dates/times, logger for structured logs, and json_serializable/freezed for data classes.
YAGNI (You Aren’t Gonna Need It)
Don’t build screens, widgets, or services “just in case.” Only add features when they’re actively required by your app’s user flows.
SOLID Principles & Extensibility
Structure your Dart classes so each has a single responsibility, is open for extension but closed for modification, and depends on abstractions (e.g. inject repositories via interfaces). This makes it easier to swap state-management solutions (Provider, Riverpod, BLoC) or back-end clients later.
Effective Dart Style Guide
Follow the official style rules—consistent naming, braces on the same line for functions, two-space indents, etc.—enforced via an analysis_options.yaml with lints from package:pedantic or package:effective_dart.
Strong Typing
Use explicit types on all public APIs (models, services, widget constructors). Don’t rely on dynamic; embrace Dart’s sound type system for safer refactors.
Dartdoc Comments
Document every public class, method, and property with triple-slash /// comments. Include parameter descriptions, return values, and usage examples when helpful.
Small Units of Work
Keep functions, methods, and widgets narrowly focused. If a widget’s build method exceeds ~50 lines, break it into smaller private widgets.
Modularity
Organize your app by feature (e.g. lib/features/auth/, lib/features/profile/), or into packages/plugins if you intend to share code across apps.
Safe Database Queries
When using sqflite or drift (formerly Moor) for local storage, always use parameterized queries or DAOs to prevent SQL injection.
Flexible JSON Storage
For semi-structured local data, store JSON blobs in a text column (e.g. via Drift) or use packages like hive for dynamic schemas.
Centralized Logging
Use a logger service (e.g. package:logger) configured at app startup. Route logs by level (DEBUG, INFO, WARN, ERROR) and optionally ship them to a remote server in production.
Centralized Metrics & Analytics
Wrap analytics calls (Firebase Analytics, Mixpanel) in a single service. Collect key events (screen views, button taps) and expose a dashboard or debug overlay during development.
Configuration & Build Flavors
Load environment variables with flutter_dotenv or a similar package, and define Android/iOS flavors (e.g. dev, staging, prod) so you can safely swap API endpoints or feature flags.
Shared Utilities (utils.dart)
Keep non–UI helper functions (date formatters, validators, extension methods) in a centralized lib/utils/ folder.
Test Fixtures & Mock Data
Place reusable test data in test/fixtures/ and use factories or builder functions to generate consistent models for unit and widget tests.
Efficient Rendering
• Mark immutable widgets const wherever possible.
• Avoid unnecessary setState() calls—use selective rebuilding with ValueListenableBuilder, Consumer, or BLoC streams.
Meaningful Return Types
Services should return Future<T> or Stream<T> wrapped in Either/Result types (e.g. from package:dartz) to clearly signal success vs. failure.
Adopt Latest SDK Versions
Target the latest stable Dart (≥ 3.0) and Flutter releases to benefit from language and performance improvements.
Automate with Scripts
Define common commands in your pubspec.yaml scripts or a top-level Makefile (e.g. make test, make format, make analyze, make build).
Graceful Error Handling
Wrap async calls in try/catch, surface user-friendly error messages in the UI, and log full stack traces for debugging.
Secrets Management
Never hard-code API keys or credentials. Store them in .env files (excluded from Git) and inject via flutter_dotenv or platform-specific secure storage.
Follow Specifications Exactly
Match wireframes and API contracts precisely. When requirements are ambiguous, clarify before implementation begins.
Comprehensive Documentation
Keep your README up to date with setup instructions, folder structure overview, and how to run/build/test the app. Use inline comments sparingly to explain non-obvious logic.
Local Database via Drift
Use Drift to define typed data classes, DAOs, and migrations. Generate code with build_runner to keep models in sync.
Form & Data Validation
Validate user input at the form level using TextFormField validators or packages like flutter_form_builder.
Asynchronous Programming
Use async/await and StreamBuilder for real-time updates. Avoid blocking the UI thread with long-running tasks—move them to isolates if needed.
HTTP & REST Integration
Use http or dio clients with interceptors for headers, retries, and logging. Decode JSON into typed models (via json_serializable).
API Versioning
Include version segments in your base URLs (e.g. https://api.example.com/v1/) so you can upgrade back-end contracts without breaking clients.
Rate Limiting & Throttling
Implement request throttling in your network layer (e.g. with Dio interceptors) to avoid flooding back-end services.
Authentication & Authorization
Use firebase_auth, OAuth flows, or custom token services. Securely store tokens with flutter_secure_storage and refresh as needed.
Robust Error Feedback in UI
Distinguish loading, success, and error states with dedicated widgets (e.g. AsyncSnapshot states, FutureBuilder, or custom BLoC states).
Pubspec Dependency Management
Pin dependency versions in pubspec.yaml, run flutter pub upgrade --major-versions judiciously, and audit with flutter pub outdated.
Automatic Code Formatting
Enforce formatting with dart format . or integrate with your IDE’s “format on save.”
Static Analysis & Linting
Run dart analyze regularly, and enable strict rules in analysis_options.yaml (e.g. avoid_print, prefer_const_constructors).
Resource Cleanup
Dispose AnimationController, StreamSubscription, TextEditingController, and other disposable objects in State.dispose().
Favor Immutability
Define data classes as @freezed or with const constructors; make all fields final to prevent accidental mutation.
Makefile / Script Targets
Include targets for build (make build), run (make run), test (make test), lint/format (make analyze, make format), clean (make clean), code-gen (make gen), etc.