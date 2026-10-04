/*
# Create documents table and storage bucket

## Purpose
Adds a document sharing feature to the admin panel. Admins can upload
PDF/image files to a Supabase Storage bucket and share them with a title
and optional description. Documents are visible to anyone with the link
(public read on the bucket), but only authenticated admins can create or
delete them.

## New Tables
- `documents`
  - `id` (uuid, primary key)
  - `title` (text, not null) — display name for the document
  - `description` (text, nullable) — optional notes about the document
  - `file_path` (text, not null) — path in the `documents` storage bucket
  - `file_url` (text, not null) — public URL to the file
  - `file_type` (text, nullable) — MIME type of the uploaded file
  - `file_size` (bigint, nullable) — file size in bytes
  - `created_at` (timestamptz, default now())

## Storage
- Creates a public storage bucket named `documents`.
- Public read so anyone with the link can view/download shared documents.
- Upload and delete are restricted to authenticated users (admins).

## Security
- RLS enabled on `documents` table.
- SELECT: anyone (anon + authenticated) can see the list of documents.
- INSERT / UPDATE / DELETE: only authenticated users (admins).
*/

CREATE TABLE IF NOT EXISTS documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  file_path text NOT NULL,
  file_url text NOT NULL,
  file_type text,
  file_size bigint,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_select_documents" ON documents;
CREATE POLICY "anon_select_documents"
ON documents FOR SELECT
TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "auth_insert_documents" ON documents;
CREATE POLICY "auth_insert_documents"
ON documents FOR INSERT
TO authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "auth_update_documents" ON documents;
CREATE POLICY "auth_update_documents"
ON documents FOR UPDATE
TO authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "auth_delete_documents" ON documents;
CREATE POLICY "auth_delete_documents"
ON documents FOR DELETE
TO authenticated USING (true);

-- Create the storage bucket (public so links are shareable)
INSERT INTO storage.buckets (id, name, public)
VALUES ('documents', 'documents', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies: public read, authenticated write
DROP POLICY IF EXISTS "anon_read_documents_bucket" ON storage.objects;
CREATE POLICY "anon_read_documents_bucket"
ON storage.objects FOR SELECT
TO anon, authenticated
USING (bucket_id = 'documents');

DROP POLICY IF EXISTS "auth_upload_documents_bucket" ON storage.objects;
CREATE POLICY "auth_upload_documents_bucket"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'documents');

DROP POLICY IF EXISTS "auth_update_documents_bucket" ON storage.objects;
CREATE POLICY "auth_update_documents_bucket"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'documents');

DROP POLICY IF EXISTS "auth_delete_documents_bucket" ON storage.objects;
CREATE POLICY "auth_delete_documents_bucket"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'documents');
