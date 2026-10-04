/*
# Add student_number to feedback_responses

## Purpose
Stores which "Student N" slot the student selected when submitting feedback.
This replaces the free-text student_name approach with a numbered identification
system (Student 1, Student 2, ... up to the feedback limit).

## Changes
- Added `student_number` (int, nullable) to `feedback_responses`.
- RLS policies unchanged — column inherits existing policies.
*/

ALTER TABLE feedback_responses
ADD COLUMN IF NOT EXISTS student_number int;
