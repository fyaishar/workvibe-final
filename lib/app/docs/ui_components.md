# WorkVibe UI Component Documentation

This document provides comprehensive guidance on using the WorkVibe UI components and theme system.

## Table of Contents

1. [Theme System](#theme-system)
2. [Session Cards](#session-cards)
3. [Status Visualization](#status-visualization)
4. [Input Fields](#input-fields)
5. [Feedback Components](#feedback-components)
6. [Layout Guidelines](#layout-guidelines)

## Theme System

### Overview

WorkVibe uses a dark theme-based UI system (mandatory per PRD) with specific gray shades and accent colors. The theme system is defined in the following files:

- `colors.dart`: Color definitions
- `text_styles.dart`: Typography styles
- `spacing.dart`: Spacing constants
- `theme.dart`: Theme configuration

### Colors

The color palette consists of:

```dart
// Base background colors
static const Color appBackground = Color(0xFF1A1A1A); // "really dark gray"
static const Color moduleBackground = Color(0xFF252525); // "slightly darker gray"

// Session card colors
static const Color sessionCardBackground = Color(0xFF1A1A1A);
static const Color sessionCardBorder = Color(0xFF3A3A3A);

// Text colors
static const Color primaryText = Color(0xFFFFFFFF);
static const Color secondaryText = Color(0xFFAAAAAA);

// Status colors
static const Color active = Color(0xFFE53935); // Accent color
static const Color break_ = Color(0xFF777777); // Dimmed for break
static const Color idle = Color(0xFF444444); // More dimmed for idle
```

Always use these color constants rather than hardcoding color values to ensure consistency across the application.

### Text Styles

Use predefined text styles for consistent typography:

```dart
// Access text styles
Text('Username', style: TextStyles.username);
Text('Task description', style: TextStyles.task);
Text('Project name', style: TextStyles.project);
```

### Spacing

Standard spacing values for margin and padding:

```dart
// Spacing examples
padding: EdgeInsets.all(Spacing.medium),
margin: EdgeInsets.symmetric(
  horizontal: Spacing.small,
  vertical: Spacing.medium,
),
SizedBox(height: Spacing.large),
```

## Session Cards

### Standard Session Card

For displaying other users' sessions:

```dart
SessionCard(
  username: 'John Doe',
  task: 'Working on UI design',
  projectOrGoal: 'WorkVibe App',
  status: SessionStatus.active, // Options: active, break_, idle
  durationLevel: 4, // 1-8 representing session duration
  isPersonal: false,
)
```

### Personal Session Card (Pre-Start)

For the initial state of the user's own session:

```dart
SessionCard(
  username: 'You',
  task: '',
  projectOrGoal: '',
  status: SessionStatus.active,
  durationLevel: 1,
  isPersonal: true,
  personalSessionState: PersonalSessionState.preStart,
  taskController: _taskController,
  projectController: _projectController,
  onStart: () {
    // Handle session start
  },
)
```

### Personal Session Card (Active)

For the active state of the user's own session:

```dart
SessionCard(
  username: 'You',
  task: 'My current task',
  projectOrGoal: 'My project',
  status: SessionStatus.active, // Can be changed to break_ or idle
  durationLevel: 5, // 1-8 representing session duration
  isPersonal: true,
  personalSessionState: PersonalSessionState.active,
  timeIndicator: 'Started 23m ago',
  onPause: () {
    // Handle pause action
  },
  onTaskComplete: (completed) {
    // Handle task completion state change
  },
  isTaskCompleted: false,
  taskProgress: 0.5, // 0.0 to 1.0
)
```

## Status Visualization

Use the StatusVisualizer to apply appropriate visual effects based on user status:

```dart
StatusVisualizer(
  status: SessionStatus.active, // Options: active, break_, idle
  showLabel: true, // Set to false to hide status label
  labelText: 'Custom Label', // Optional custom label
  labelAlignment: Alignment.topRight, // Position the label
  child: YourWidget(), // Wrap any widget
)
```

Effects applied based on status:
- Active: No dimming (100% opacity)
- Break: Moderate dimming (60% opacity)
- Idle: Significant dimming (30% opacity)

## Input Fields

### Standard Text Field

```dart
CustomTextField(
  controller: _textController,
  placeholder: 'Enter text here',
  hint: 'Optional hint text below the field',
  label: 'Field Label',
  isRequired: true, // Shows required indicator (*)
  prefixIcon: Icons.person,
  suffixIcon: Icons.clear,
  onSuffixIconPressed: () {
    // Handle suffix icon tap
  },
  onChanged: (value) {
    // Handle text changes
  },
  onSubmitted: (value) {
    // Handle submission
  },
  errorText: 'Error message', // Shows error state
)
```

### Field Variations

- **Password Field**:
  ```dart
  CustomTextField(
    controller: _passwordController,
    placeholder: 'Enter password',
    obscureText: true,
    prefixIcon: Icons.lock,
  )
  ```

- **Multi-line Input**:
  ```dart
  CustomTextField(
    controller: _notesController,
    placeholder: 'Enter notes',
    maxLines: 5,
    expands: false,
  )
  ```

## Feedback Components

### Connection Status

Shows network connection state:

```dart
ConnectionStatus(
  state: NetworkState.connected, // Options: connected, connecting, disconnected
  onReconnect: () {
    // Handle reconnect request
  },
)
```

### Notification Toast

For displaying temporary feedback messages:

```dart
NotificationToast(
  message: 'Action completed successfully',
  type: ToastType.success, // Options: success, error, warning, info
  onDismiss: () {
    // Handle dismiss
  },
)
```

### Loading Spinner

For indicating loading states:

```dart
LoadingSpinner(
  size: LoadingSize.medium, // Options: small, medium, large
  label: 'Loading...', // Optional text
)
```

### Error Display

For displaying detailed error information:

```dart
ErrorDisplay(
  title: 'Connection Error',
  message: 'Could not connect to the server.',
  code: '404',
  suggestion: 'Check your internet connection and try again.',
  onRetry: () {
    // Handle retry action
  },
)
```

## Layout Guidelines

### Responsive Design

- Use flexible layouts with Expanded and Flexible widgets
- Set minimum window dimensions to 320x480px
- Ensure elements scale proportionally
- Use MediaQuery to adapt to different screen sizes:

```dart
final screenWidth = MediaQuery.of(context).size.width;
final screenHeight = MediaQuery.of(context).size.height;

// Responsive container example
Container(
  width: screenWidth * 0.8, // 80% of screen width
  constraints: BoxConstraints(
    maxWidth: 600, // Maximum width
    minWidth: 300, // Minimum width
  ),
  child: YourWidget(),
)
```

### Single-Screen Interface

The main application uses a single-screen interface with two primary states:

1. **Start State**: Shows the personal session card in pre-start state (no other users visible)
2. **Active State**: Shows the personal session card in active state along with other users' sessions

Navigation between states happens when the user starts a session.

---

## Best Practices

1. Always use the theme system constants instead of hardcoded values
2. Maintain component consistency by using the provided widgets
3. Ensure responsive behavior for all screen sizes
4. Follow accessibility guidelines for text contrast and tap targets
5. Use the status visualization consistently for user states
6. Test on multiple screen sizes and orientations

For questions or contribution guidelines, contact the development team.