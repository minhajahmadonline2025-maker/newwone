/*
# Usthad Feedback Collection System — Schema

## Purpose
Creates the full database schema for the Usthad Feedback Collection Software.
Students submit feedback (star rating + optional comment) for a specific
Usthad/subject within a class. Admins manage staff, subjects, limits, view
feedback, and generate PDF reports.

## Tables

1. `classes` — Class 1 through Class 10
   - id (uuid PK), name (text), sort_order (int)

2. `usthads` — Teacher master list (unique by name)
   - id (uuid PK), name (text), created_at

3. `subjects` — Subject master list (unique by name)
   - id (uuid PK), name (text)
   - "Thasawuf and Aqeeda" is ONE row, "Mantiq and Philosophy" is ONE row.
   - Only comma-separated entries create separate rows.

4. `class_usthads` — Links an Usthad to a Class (many-to-many)
   - id (uuid PK), class_id (FK→classes), usthad_id (FK→usthads)
   - UNIQUE(class_id, usthad_id)

5. `class_usthad_subjects` — Subjects taught by a specific Usthad in a specific Class
   - id (uuid PK), class_usthad_id (FK→class_usthads), subject_id (FK→subjects)
   - feedback_limit (int, nullable — overrides global default when set)
   - UNIQUE(class_usthad_id, subject_id)

6. `feedback_settings` — Single-row global settings table
   - id (int PK, always 1), default_feedback_limit (int, default 5),
     require_student_name (bool, default false), institution_name (text)

7. `feedback_responses` — Individual feedback submissions
   - id (uuid PK), class_usthad_subject_id (FK→class_usthad_subjects),
     rating (int 1–5), comment (text, nullable), student_name (text, nullable),
     created_at

## Security / RLS

- Students submit feedback without login (anon role).
- Admin operations require authentication (Supabase email/password auth).

Policy breakdown:
- `classes`, `usthads`, `subjects`, `class_usthads`, `class_usthad_subjects`,
  `feedback_settings`: SELECT open to anon+authenticated (students need to
  read structure). INSERT/UPDATE/DELETE restricted to authenticated (admin).
- `feedback_responses`: SELECT open to anon+authenticated (students need to
  count responses for limit check; admin views them). INSERT open to
  anon+authenticated (students submit). UPDATE/DELETE restricted to
  authenticated (admin reset only).

## Notes
- `feedback_limit` on `class_usthad_subjects` is nullable. When NULL, the
  global `default_feedback_limit` from `feedback_settings` applies.
- `student_name` is nullable — only populated when `require_student_name` is
  enabled in settings.
*/

-- classes
CREATE TABLE IF NOT EXISTS classes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  sort_order int NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "read_classes" ON classes;
CREATE POLICY "read_classes" ON classes FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "insert_classes" ON classes;
CREATE POLICY "insert_classes" ON classes FOR INSERT
  TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "update_classes" ON classes;
CREATE POLICY "update_classes" ON classes FOR UPDATE
  TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "delete_classes" ON classes;
CREATE POLICY "delete_classes" ON classes FOR DELETE
  TO authenticated USING (true);

-- usthads
CREATE TABLE IF NOT EXISTS usthads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE usthads ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "read_usthads" ON usthads;
CREATE POLICY "read_usthads" ON usthads FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "insert_usthads" ON usthads;
CREATE POLICY "insert_usthads" ON usthads FOR INSERT
  TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "update_usthads" ON usthads;
CREATE POLICY "update_usthads" ON usthads FOR UPDATE
  TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "delete_usthads" ON usthads;
CREATE POLICY "delete_usthads" ON usthads FOR DELETE
  TO authenticated USING (true);

-- subjects
CREATE TABLE IF NOT EXISTS subjects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "read_subjects" ON subjects;
CREATE POLICY "read_subjects" ON subjects FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "insert_subjects" ON subjects;
CREATE POLICY "insert_subjects" ON subjects FOR INSERT
  TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "update_subjects" ON subjects;
CREATE POLICY "update_subjects" ON subjects FOR UPDATE
  TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "delete_subjects" ON subjects;
CREATE POLICY "delete_subjects" ON subjects FOR DELETE
  TO authenticated USING (true);

-- class_usthads
CREATE TABLE IF NOT EXISTS class_usthads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id uuid NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  usthad_id uuid NOT NULL REFERENCES usthads(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(class_id, usthad_id)
);
ALTER TABLE class_usthads ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "read_class_usthads" ON class_usthads;
CREATE POLICY "read_class_usthads" ON class_usthads FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "insert_class_usthads" ON class_usthads;
CREATE POLICY "insert_class_usthads" ON class_usthads FOR INSERT
  TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "update_class_usthads" ON class_usthads;
CREATE POLICY "update_class_usthads" ON class_usthads FOR UPDATE
  TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "delete_class_usthads" ON class_usthads;
CREATE POLICY "delete_class_usthads" ON class_usthads FOR DELETE
  TO authenticated USING (true);

-- class_usthad_subjects
CREATE TABLE IF NOT EXISTS class_usthad_subjects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  class_usthad_id uuid NOT NULL REFERENCES class_usthads(id) ON DELETE CASCADE,
  subject_id uuid NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  feedback_limit int,
  created_at timestamptz DEFAULT now(),
  UNIQUE(class_usthad_id, subject_id)
);
ALTER TABLE class_usthad_subjects ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "read_class_usthad_subjects" ON class_usthad_subjects;
CREATE POLICY "read_class_usthad_subjects" ON class_usthad_subjects FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "insert_class_usthad_subjects" ON class_usthad_subjects;
CREATE POLICY "insert_class_usthad_subjects" ON class_usthad_subjects FOR INSERT
  TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "update_class_usthad_subjects" ON class_usthad_subjects;
CREATE POLICY "update_class_usthad_subjects" ON class_usthad_subjects FOR UPDATE
  TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "delete_class_usthad_subjects" ON class_usthad_subjects;
CREATE POLICY "delete_class_usthad_subjects" ON class_usthad_subjects FOR DELETE
  TO authenticated USING (true);

-- feedback_settings (single row)
CREATE TABLE IF NOT EXISTS feedback_settings (
  id int PRIMARY KEY DEFAULT 1,
  default_feedback_limit int NOT NULL DEFAULT 5,
  require_student_name boolean NOT NULL DEFAULT false,
  institution_name text NOT NULL DEFAULT 'Usthad Feedback System',
  CONSTRAINT single_row CHECK (id = 1)
);
ALTER TABLE feedback_settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "read_feedback_settings" ON feedback_settings;
CREATE POLICY "read_feedback_settings" ON feedback_settings FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "insert_feedback_settings" ON feedback_settings;
CREATE POLICY "insert_feedback_settings" ON feedback_settings FOR INSERT
  TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "update_feedback_settings" ON feedback_settings;
CREATE POLICY "update_feedback_settings" ON feedback_settings FOR UPDATE
  TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "delete_feedback_settings" ON feedback_settings;
CREATE POLICY "delete_feedback_settings" ON feedback_settings FOR DELETE
  TO authenticated USING (true);

-- feedback_responses
CREATE TABLE IF NOT EXISTS feedback_responses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  class_usthad_subject_id uuid NOT NULL REFERENCES class_usthad_subjects(id) ON DELETE CASCADE,
  rating int NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment text,
  student_name text,
  created_at timestamptz DEFAULT now()
);
ALTER TABLE feedback_responses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "read_feedback_responses" ON feedback_responses;
CREATE POLICY "read_feedback_responses" ON feedback_responses FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "insert_feedback_responses" ON feedback_responses;
CREATE POLICY "insert_feedback_responses" ON feedback_responses FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "update_feedback_responses" ON feedback_responses;
CREATE POLICY "update_feedback_responses" ON feedback_responses FOR UPDATE
  TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "delete_feedback_responses" ON feedback_responses;
CREATE POLICY "delete_feedback_responses" ON feedback_responses FOR DELETE
  TO authenticated USING (true);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_class_usthads_class ON class_usthads(class_id);
CREATE INDEX IF NOT EXISTS idx_class_usthads_usthad ON class_usthads(usthad_id);
CREATE INDEX IF NOT EXISTS idx_class_usthad_subjects_cu ON class_usthad_subjects(class_usthad_id);
CREATE INDEX IF NOT EXISTS idx_feedback_responses_cus ON feedback_responses(class_usthad_subject_id);

-- Insert default settings row
INSERT INTO feedback_settings (id, default_feedback_limit, require_student_name, institution_name)
VALUES (1, 5, false, 'Usthad Feedback System')
ON CONFLICT (id) DO NOTHING;