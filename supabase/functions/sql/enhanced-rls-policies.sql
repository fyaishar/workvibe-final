-- Enhanced RLS policies for Workvibe tables
-- These policies restrict data access to ensure users can only view and modify their own data

-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE logbooks ENABLE ROW LEVEL SECURITY;
ALTER TABLE task_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE logbook_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE logbook_projects ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can read own data" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;
DROP POLICY IF EXISTS "Users can insert own data" ON users;
DROP POLICY IF EXISTS "No user deletion" ON users;

DROP POLICY IF EXISTS "Users can read own sessions" ON sessions;
DROP POLICY IF EXISTS "Users can insert own sessions" ON sessions;
DROP POLICY IF EXISTS "Users can update own sessions" ON sessions;
DROP POLICY IF EXISTS "No session deletion" ON sessions;

DROP POLICY IF EXISTS "Users can read own projects" ON projects;
DROP POLICY IF EXISTS "Users can insert own projects" ON projects;
DROP POLICY IF EXISTS "Users can update own projects" ON projects;
DROP POLICY IF EXISTS "No project deletion" ON projects;

DROP POLICY IF EXISTS "Users can read own tasks" ON tasks;
DROP POLICY IF EXISTS "Users can insert own tasks" ON tasks;
DROP POLICY IF EXISTS "Users can update own tasks" ON tasks;
DROP POLICY IF EXISTS "No task deletion" ON tasks;

DROP POLICY IF EXISTS "Public rooms read" ON rooms;
DROP POLICY IF EXISTS "Admin rooms write" ON rooms;

-- Users table policies
CREATE POLICY "Users can read own data" 
ON users FOR SELECT 
USING (auth.uid() = id);

CREATE POLICY "Users can update own data" 
ON users FOR UPDATE 
USING (auth.uid() = id);

CREATE POLICY "Users can insert own data" 
ON users FOR INSERT 
WITH CHECK (auth.uid() = id);

CREATE POLICY "No user deletion" 
ON users FOR DELETE 
USING (false);

-- Sessions table policies
CREATE POLICY "Users can read own sessions" 
ON sessions FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sessions" 
ON sessions FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own sessions" 
ON sessions FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "No session deletion" 
ON sessions FOR DELETE 
USING (false);

-- Projects table policies
CREATE POLICY "Users can read own projects" 
ON projects FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own projects" 
ON projects FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own projects" 
ON projects FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "No project deletion" 
ON projects FOR DELETE 
USING (false);

-- Tasks table policies
CREATE POLICY "Users can read own tasks" 
ON tasks FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tasks" 
ON tasks FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tasks" 
ON tasks FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "No task deletion" 
ON tasks FOR DELETE 
USING (false);

-- Rooms table policies (public data, but protected write)
CREATE POLICY "Public rooms read" 
ON rooms FOR SELECT 
USING (true);

CREATE POLICY "Admin rooms write" 
ON rooms FOR INSERT 
WITH CHECK (auth.uid() IN (
  SELECT id FROM users WHERE is_admin = true
));

CREATE POLICY "Admin rooms update" 
ON rooms FOR UPDATE 
USING (auth.uid() IN (
  SELECT id FROM users WHERE is_admin = true
));

-- Logbooks table policies
CREATE POLICY "Users can read own logbooks" 
ON logbooks FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own logbooks" 
ON logbooks FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own logbooks" 
ON logbooks FOR UPDATE 
USING (auth.uid() = user_id);

CREATE POLICY "No logbook deletion" 
ON logbooks FOR DELETE 
USING (false);

-- Join table policies: task_sessions
CREATE POLICY "Users can read own task_sessions" 
ON task_sessions FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM sessions 
    WHERE sessions.id = task_sessions.session_id 
    AND sessions.user_id = auth.uid()
  )
);

CREATE POLICY "Users can insert own task_sessions" 
ON task_sessions FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM sessions 
    WHERE sessions.id = task_sessions.session_id 
    AND sessions.user_id = auth.uid()
  )
);

-- Join table policies: logbook_sessions
CREATE POLICY "Users can read own logbook_sessions" 
ON logbook_sessions FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM logbooks 
    WHERE logbooks.id = logbook_sessions.logbook_id 
    AND logbooks.user_id = auth.uid()
  )
);

CREATE POLICY "Users can insert own logbook_sessions" 
ON logbook_sessions FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM logbooks 
    WHERE logbooks.id = logbook_sessions.logbook_id 
    AND logbooks.user_id = auth.uid()
  )
);

-- Join table policies: logbook_projects
CREATE POLICY "Users can read own logbook_projects" 
ON logbook_projects FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM logbooks 
    WHERE logbooks.id = logbook_projects.logbook_id 
    AND logbooks.user_id = auth.uid()
  )
);

CREATE POLICY "Users can insert own logbook_projects" 
ON logbook_projects FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM logbooks 
    WHERE logbooks.id = logbook_projects.logbook_id 
    AND logbooks.user_id = auth.uid()
  )
);

-- Add is_admin column to users table if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'users' AND column_name = 'is_admin'
  ) THEN
    ALTER TABLE users ADD COLUMN is_admin BOOLEAN DEFAULT false;
  END IF;
END
$$; 