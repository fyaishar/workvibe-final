Product Requirements Document: Work Vibe v1.0 (Enhanced)

1. Introduction

1.1. Product: Work Vibe
1.2. Overview: Work Vibe aims to be a modern, cross-platform application (initially Web and macOS) enabling real-time sharing of current work tasks among active users. Built with Flutter for the frontend and likely Node.js with Supabase (or Firebase) for the backend, it prioritizes live updates, simplicity, and a sense of shared focus. This document outlines the requirements for Version 1.0.
1.3. Goal: To create a simple, reliable platform for users to share their active task, view others' tasks in real-time, and gain passive awareness of colleagues' or community members' current work focus. Foster a sense of shared presence.
1.4. Version: 1.0
1.5. Date: 2025-04-30
1.6. Author: Gemini (Generated based on user transcript, enhanced with structural elements)
2. Goals 

Provide a simple mechanism for users to declare and update their current task and optional context (project/goal).
Create a shared, real-time view of active users and their declared tasks.
Offer visual cues for session duration (border thickness) and user status (active, paused, idle).
Ensure the system is scalable to support a large number of concurrent users (target: 100k).
Establish a clean, maintainable codebase following Flutter best practices.
Implement basic user identification within a session (Username display). (Note: Full authentication is out of scope for v1.0 but planned for future iterations).
3. Core Features & Functionality

3.1. Session Management:
Start/End Session based on task input and activity timers.
Enter task (required) and project/goal (optional).
Real-time joining/leaving updates in the shared view.
3.2. Real-time Task Sharing:
Broadcast user's task/project updates instantly to other participants.
Display other active users' sessions (username, task, project/goal).
3.3. Status Updates & Visual Cues:
Pause/Resume functionality with visual indicators (dimming, "Break" label) for others.
Idle state detection (>30 min pause) with distinct visual indication (further dimming, bottom placement).
Automatic session termination (>60 min pause or 60s task completion timeout).
Dynamic border thickness based on active session duration (8 levels: 5m to 300m).
3.4. User Identity (Basic):
Display a "Username" associated with each session. (V1 assumes username is provided/pre-configured; no login required).
3.5. Single-Screen Interface:
Distinct "Start" and "Active" states within one primary view.
Consistent layout with Personal Session module at the bottom.
4. User Experience (UX)

4.1. Key User Flows:
Start Session: Open App -> See Start Prompt -> Enter Task -> Press Enter/Click Start -> Transition to Active State.
Update Task: In Active State -> Click Task Text -> Edit Text -> Press Enter -> See Updated Task, Others See Update.
Complete Task: Click Checkbox -> Fields Clear -> (Within 60s) Enter New Task -> Session Continues OR (After 60s) -> Session Ends, Return to Start State.
Take Break: Click Pause -> Status changes for others -> Click Play -> Status reverts.
View Others: In Active State -> See list of other users' session modules with their tasks, status, border thickness.
4.2. UI/UX Considerations:
Theme: Dark theme mandatory ("really dark gray" base, "slightly darker gray" module).
Responsiveness: Layout should adapt gracefully between typical web/desktop window sizes on macOS and Web.
Clarity: Clear visual distinction between personal session and others' sessions (size, placement). Status indicators (Break, Idle, Border) must be unambiguous.
Feedback: Input fields should have clear placeholder text. Actions (start, pause, complete) should provide immediate visual feedback.
Loading/Connection States: Need visual indication if connecting to the real-time service or if the connection is lost. (Implicit requirement for usability).
Error Handling: Basic error handling for scenarios like failing to connect to the backend.
5. Technical Architecture

5.1. Frontend: Flutter (targeting Web, macOS initially)
5.2. Backend: Node.js (preferred)
5.3. Database: Supabase (preferred, leveraging Realtime features), Firebase Realtime Database (alternative)
5.4. Real-time Communication: WebSockets (via Supabase Realtime, Firebase Realtime DB, or a dedicated service like Socket.IO on Node.js).
5.5. Proposed Frontend Project Structure (Illustrative):
lib/
├── app/                  # App setup, routing, theme
│   ├── app.dart
│   └── theme/
│       └── work_vibe_theme.dart
├── core/                 # Core utilities, services, base classes
│   ├── config/           # Environment config
│   ├── errors/           # Error handling, exceptions
│   ├── network/          # WebSocket client/service wrapper
│   └── state/            # Base state management logic
├── features/             # Feature modules
│   └── session/          # Main Work Vibe feature
│       ├── data/         # Data sources (remote), models (Task, SessionInfo)
│       ├── domain/       # Repositories, use cases (optional for V1 simplicity)
│       ├── presentation/ # UI (Widgets, Screens), State management (Notifiers/Blocs)
│       │   ├── manager/  # State management classes
│       │   └── widgets/  # Reusable widgets for this feature
│       └── session_screen.dart # Main screen entry point
├── shared/               # Widgets/Utils shared across features (minimal for V1)
│   └── widgets/
└── main.dart             # Application entry point
5.6. Core Components (Frontend):
Real-time Service Wrapper (abstracting WebSocket/DB connection).
State Management Solution (e.g., Riverpod/Provider recommended for Flutter).
Session State Manager (handling current task, project, status, timer logic).
Active Users List Manager (handling updates from the real-time service).
UI Components (Personal Session Module, Other Session Module).
5.7. Data Models:
SessionInfo (UserID/Username, Task, ProjectGoal, Status, StartTime, LastActiveTime)
Task (Text content)
ProjectGoal (Text content)
UserStatus (Enum: Active, Paused, Idle)
5.8. State Management:
Utilize Provider or Riverpod for dependency injection and state propagation.
Manage personal session state locally within the PersonalSessionModule.
Manage the list of other active users via a central provider/notifier listening to the real-time service.
Keep state updates efficient, especially for the list of other users.
6. Development Roadmap (Phases)

6.1. Foundation Phase:
Setup Flutter project (Web, macOS targets).
Implement basic project structure and core utilities (theme, navigation placeholders).
Setup preferred state management solution.
Basic UI shell with placeholder Start/Active states.
6.2. Backend & Real-time Setup:
Setup Node.js backend (if needed beyond BaaS).
Setup Supabase/Firebase database and real-time listeners.
Define data structures/models on the backend.
Implement basic WebSocket connection/real-time subscription logic in Flutter.
6.3. Core Session Feature:
Implement Personal Session Module UI (Start state inputs, Active state display).
Implement Start/Update/Complete task logic (client-side).
Integrate task updates with backend/real-time service (send updates).
Implement Pause/Resume logic and status updates (client-side & broadcast).
Implement session timers (completion grace period, idle timeout, end timeout).
6.4. Shared View Implementation:
Implement UI for displaying other users' sessions.
Consume real-time updates (users joining, leaving, updating tasks, changing status).
Implement dynamic border thickness rendering based on session duration data from backend/real-time updates.
6.5. Polish & Testing:
Refine UI/UX, add loading/error states.
Implement basic unit/widget tests for key components/logic.
Cross-platform testing (Web, macOS).
Address scalability concerns in backend logic.
7. Logical Dependency Chain

Environment & Foundation: Project setup, basic structure, theme.
Backend/Real-time Service: Database schema, real-time endpoints/listeners ready.
Frontend Real-time Connection: Flutter app can connect and receive basic messages.
Personal Session Logic: User can start, update, complete, pause their own session locally and broadcast changes.
Shared Session View: Frontend can receive and display other users' sessions and their real-time updates (tasks, status, borders).
Timers & Auto-End: Inactivity and completion timers correctly manage session state and termination.
Testing & Refinement: Ensure stability, usability, and platform consistency.
8. Risks and Mitigations

8.1. Scalability (100k Users):
Risk: Backend/database cannot handle the load of concurrent connections and real-time updates.
Mitigation: Choose Supabase/Firebase tiers capable of scaling; design backend logic efficiently (minimize broadcast data); potentially shard users or use optimized data structures if needed; load test infrastructure.
8.2. Real-time Synchronization Complexity:
Risk: State inconsistencies between clients, delayed updates, connection handling issues.
Mitigation: Use robust real-time features of Supabase/Firebase; implement reliable connection status handling and reconnection logic in Flutter; keep messages small; potentially use sequence numbers or timestamps for ordering if needed.
8.3. Cross-Platform Consistency (Web/macOS):
Risk: UI rendering differences or behavioral inconsistencies between platforms.
Mitigation: Use standard Flutter widgets where possible; test frequently on both target platforms; be mindful of platform-specific APIs (minimal expected for V1).
8.4. State Management Complexity:
Risk: Difficult-to-manage state, especially with asynchronous updates from the real-time service.
Mitigation: Adopt a clear state management pattern (Provider/Riverpod); clearly define responsibilities of different state managers; use immutable state where appropriate.
9. Appendix

9.1. Technical Stack:
Flutter SDK (latest stable)
Frontend State Management: Provider or Riverpod (TBD)
Backend: Node.js (optional/if needed beyond BaaS)
Database/Real-time: Supabase (preferred) or Firebase Realtime Database
Testing: flutter_test (widget testing), potentially mockito/mocktail for mocking services.
9.2. Development Standards:
Follow Effective Dart style guide.
Use a standard Git workflow (e.g., Gitflow).
Basic code reviews for key features.
Comment critical or complex logic sections.
9.3. Performance Goals/Metrics (V1 Targets):
Real-time Updates Latency: Aim for sub-second propagation of task/status changes under moderate load.
Client Performance: Maintain smooth UI performance (target 60fps) on target platforms during typical use (e.g., <50 concurrent sessions displayed).
Concurrency: Backend architecture designed with 100k concurrent users in mind.