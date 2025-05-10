# Workvibe - Flutter Productivity App

A Flutter-based productivity application using Supabase for backend services.

## Project Structure

- `lib/` - Flutter application source code
- `test/` - Test files for the application
- `old_backend/` - Legacy Node.js backend code (for reference only)
- `docs/` - Project documentation
  - [Database Technology](docs/database_technology.md) - Official documentation on Supabase usage

## About the old_backend Directory

The `old_backend/` directory contains a legacy Node.js implementation that served as the original backend for this application. This code is maintained **for reference purposes only** and provides context for:

1. The conceptual data model design
2. Real-time functionality expectations
3. Original application workflows

**Important:** The application has migrated to Supabase for all backend services. No code from the old_backend directory is actively used in the current implementation.

## Supabase Schema

The following SQL query was used to set up the Supabase database schema:

```sql
-- Create tables with proper relationships, UUIDs, and timestamps

-- 1. Create rooms table first (since it's referenced by sessions)
CREATE TABLE rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL UNIQUE,
  active_sessions INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Create users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  username TEXT NOT NULL UNIQUE,
  email TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  current_session UUID,  -- Will add foreign key constraint after sessions table is created
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Create projects table
CREATE TABLE projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  description TEXT,
  start_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  end_time TIMESTAMP WITH TIME ZONE,
  active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Create tasks table
CREATE TABLE tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  progress_dots INTEGER DEFAULT 0,
  start_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  end_time TIMESTAMP WITH TIME ZONE,
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Create sessions table now that we have all referenced tables
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status TEXT NOT NULL,
  current_project UUID REFERENCES projects(id) ON DELETE SET NULL,
  current_task UUID REFERENCES tasks(id) ON DELETE SET NULL,
  room_type TEXT REFERENCES rooms(type) ON DELETE SET NULL,
  start_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  end_time TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Now add the foreign key constraint to users.current_session
ALTER TABLE users
ADD CONSTRAINT fk_current_session
FOREIGN KEY (current_session) REFERENCES sessions(id) ON DELETE SET NULL;

-- 6. Create logbooks table
CREATE TABLE logbooks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Create task_sessions join table
CREATE TABLE task_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL REFERENCES tasks(id) ON DELETE CASCADE,
  session_id UUID NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
  time_spent INTEGER DEFAULT 0, -- Time spent in seconds
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CONSTRAINT unique_task_session UNIQUE(task_id, session_id)
);
```

## Architecture

### Feature-First Architecture

The codebase is organized around features rather than layers, following a feature-first architecture pattern:

```
lib/
├── features/
│   ├── auth/             # Authentication feature
│   │   ├── repository/   # Data layer
│   │   ├── screens/      # UI components
│   │   └── state/        # Feature state
│   └── session/          # Session management feature
│       ├── data/         # Data sources
│       ├── domain/       # Business logic
│       └── presentation/ # UI components
```

Each feature is a self-contained module with its own UI components, business logic, and data access layers.

### Clean Architecture

The project follows clean architecture principles with clear separation between:

- **Presentation Layer**: UI components (screens, widgets)
- **Domain Layer**: Business logic and models
- **Data Layer**: Data sources and repositories

This separation ensures that business logic is decoupled from UI and data access concerns.

## State Management

Workvibe uses **Flutter Riverpod** for state management with:

- Provider observers for monitoring state changes
- Freezed annotations for immutable state objects 
- Separation of state from UI components

## Supabase Integration

The application leverages Supabase for multiple backend services:

### Authentication
- Email/password authentication
- OAuth providers (Google, Apple)
- Password reset functionality
- Session management with JWT

### Real-time Database
- PostgreSQL database (schema detailed above)
- Real-time data subscriptions
- Row-level security policies

### Serverless Functions
- Edge functions for server-side logic
- Webhook integrations

## UI Framework

The application uses a consistent design system with:

- Dark theme as the primary theme
- Custom fonts (Eina01)
- Material Design components with custom styling
- Component showcase for design system reference (accessible via `/showcase` route)

## Development Workflow

The project uses TaskMaster for task management:

- Task definition and tracking in `tasks/` directory
- Dependency management between tasks
- Task expansion into subtasks
- Progress tracking through task status updates

## Testing Strategy

The project includes comprehensive testing:

- **Unit Tests**: Testing individual functions and classes
- **Widget Tests**: Testing UI components in isolation
- **Integration Tests**: Testing feature workflows
- **Mocking**: Using Mockito and Mocktail for test doubles

## Getting Started

### Prerequisites

- Flutter SDK (2.10.0 or higher)
- Dart SDK (2.16.0 or higher)
- Supabase account
- Git

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/workvibe.git
   cd workvibe
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase**
   - Create a new Supabase project
   - Run the SQL schema script in the Supabase SQL editor
   - Update `lib/config/env.dart` with your Supabase URL and anon key

4. **Run the application**
   ```bash
   flutter run
   ```

For more information:
- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Documentation](https://supabase.io/docs)
- [Riverpod Documentation](https://riverpod.dev/)
