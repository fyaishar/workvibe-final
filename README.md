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

## Getting Started

This project is a Flutter application. Some helpful resources:

- [Flutter Documentation](https://docs.flutter.dev/)
- [Supabase Documentation](https://supabase.io/docs)
