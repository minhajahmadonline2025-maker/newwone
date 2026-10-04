/*
# Seed Classes, Usthads, Subjects, and Assignments

## Purpose
Preloads all 10 classes, the full Usthad roster, subject master list, and
class-specific Usthad→Subject assignments from the provided data.

## Rules
- Subjects are ONLY split on commas. "and"/"&" are part of a single subject name.
- Usthads with no subject in a class still get a class_usthads row (no subject row).
- Each unique Usthad name → one row in `usthads`.
- Each unique subject name → one row in `subjects`.
- Assignments link class → usthad → subject(s) via `class_usthads` + `class_usthad_subjects`.

## Notes
- This is idempotent: uses ON CONFLICT DO NOTHING for all inserts.
*/

-- Classes 1-10
INSERT INTO classes (name, sort_order) VALUES
('Class 1', 1), ('Class 2', 2), ('Class 3', 3), ('Class 4', 4), ('Class 5', 5),
('Class 6', 6), ('Class 7', 7), ('Class 8', 8), ('Class 9', 9), ('Class 10', 10)
ON CONFLICT DO NOTHING;

-- Usthads (all unique names from the dataset)
INSERT INTO usthads (name) VALUES
('Abdul Bari Hudawi Kari Usthad'),
('Abdul Samad Usthad'),
('Abdussamad PB Usthad'),
('Ahmad Raees KA Usthad'),
('Ahmed BK Usthad'),
('Anwar Nuhmani Usthad'),
('Ibrahim K M Usthad'),
('Ibrahim Sadik Usthad'),
('Lukuman Hakeem U S Usthad'),
('Mohammad Naufal Usthad'),
('Mohammed Najeebullah A M Usthad'),
('Muhamed Anas P Usthad'),
('Muhammed CP Usthad'),
('Muhammed Hudawi Vengad Usthad'),
('Muhammed Ishaq Usthad'),
('Muhammed Minshaj Hudawi Usthad'),
('Noufal VM Usthad'),
('Sadiq Ali Usthad'),
('Shameem Abdulla P S Usthad'),
('Ashfaque Usthad'),
('Sajjad Usthad'),
('Shamseer Usthad'),
('Ibrahim K Usthad')
ON CONFLICT (name) DO NOTHING;

-- Subjects (all unique subject names — "and" stays as ONE subject)
INSERT INTO subjects (name) VALUES
('Fiqh'),
('Malayalam'),
('Hindi'),
('English'),
('Swadf'),
('Hadeeth'),
('Social'),
('Thareeq'),
('Urdu'),
('Thasawuf'),
('Nahv'),
('Thajweed'),
('Adab'),
('Science'),
('IT'),
('T&C'),
('Aqeeda'),
('Maths'),
('Social Science'),
('Alfiyya'),
('Thafseer'),
('Biology'),
('Physics'),
('Chemistry'),
('Balaga'),
('Economics'),
('Politics'),
('Business Studies'),
('Thamaddun'),
('Computer Application'),
('History'),
('Sociology'),
('Accountancy'),
('Usul al Fiqh'),
('Political Science'),
('Thasawuf and Aqeeda'),
('Thahqeeq'),
('Fatwa'),
('U Fiqh'),
('Mantiq and Philosophy'),
('Thakassus'),
('TMDN'),
('GK'),
('UFiqh'),
('Mantiq'),
('Tahqeeq'),
('Tajveed')
ON CONFLICT (name) DO NOTHING;

-- Helper: we'll use a DO block to insert class_usthads and class_usthad_subjects
-- using subqueries to resolve IDs.

DO $$
DECLARE
  -- class name → id map via subqueries in each INSERT
BEGIN
  -- ============================================================
  -- CLASS 1
  -- ============================================================
  -- Abdul Bari Hudawi Kari Usthad — Fiqh
  INSERT INTO class_usthads (class_id, usthad_id)
    SELECT c.id, u.id FROM classes c, usthads u
    WHERE c.name='Class 1' AND u.name='Abdul Bari Hudawi Kari Usthad'
    ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id)
    SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u
    WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 1' AND u.name='Abdul Bari Hudawi Kari Usthad' AND s.name='Fiqh'
    ON CONFLICT DO NOTHING;

  -- Abdul Samad Usthad — Malayalam
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 1' AND u.name='Abdul Samad Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 1' AND u.name='Abdul Samad Usthad' AND s.name='Malayalam' ON CONFLICT DO NOTHING;

  -- Abdussamad PB Usthad — Hindi
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 1' AND u.name='Abdussamad PB Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 1' AND u.name='Abdussamad PB Usthad' AND s.name='Hindi' ON CONFLICT DO NOTHING;

  -- Ahmad Raees KA Usthad — English
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 1' AND u.name='Ahmad Raees KA Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 1' AND u.name='Ahmad Raees KA Usthad' AND s.name='English' ON CONFLICT DO NOTHING;

  -- Ahmed BK Usthad — Swarf (stored as Swadf per subject list; using Swarf as given)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 1' AND u.name='Ahmed BK Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 1' AND u.name='Ahmed BK Usthad' AND s.name='Swadf' ON CONFLICT DO NOTHING;

  -- Anwar Nuhmani Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 1' AND u.name='Anwar Nuhmani Usthad' ON CONFLICT DO NOTHING;

  -- Ibrahim K M Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 1' AND u.name='Ibrahim K M Usthad' ON CONFLICT DO NOTHING;

  -- Ibrahim Sadik Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 1' AND u.name='Ibrahim Sadik Usthad' ON CONFLICT DO NOTHING;

  -- Lukuman Hakeem U S Usthad — Hadeeth
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 1' AND u.name='Lukuman Hakeem U S Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 1' AND u.name='Lukuman Hakeem U S Usthad' AND s.name='Hadeeth' ON CONFLICT DO NOTHING;

  -- Mohammad Naufal Usthad — Social
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 1' AND u.name='Mohammad Naufal Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 1' AND u.name='Mohammad Naufal Usthad' AND s.name='Social' ON CONFLICT DO NOTHING;

  -- Mohammed Najeebullah A M Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 1' AND u.name='Mohammed Najeebullah A M Usthad' ON CONFLICT DO NOTHING;

  -- Muhamed Anas P Usthad — Thareeq
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 1' AND u.name='Muhamed Anas P Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 1' AND u.name='Muhamed Anas P Usthad' AND s.name='Thareeq' ON CONFLICT DO NOTHING;

  -- Muhammed CP Usthad — Urdu, Thasawuf
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 1' AND u.name='Muhammed CP Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 1' AND u.name='Muhammed CP Usthad' AND s.name='Urdu' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 1' AND u.name='Muhammed CP Usthad' AND s.name='Thasawuf' ON CONFLICT DO NOTHING;

  -- Muhammed Hudawi Vengad Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 1' AND u.name='Muhammed Hudawi Vengad Usthad' ON CONFLICT DO NOTHING;

  -- Muhammed Ishaq Usthad — Maths
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 1' AND u.name='Muhammed Ishaq Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 1' AND u.name='Muhammed Ishaq Usthad' AND s.name='Maths' ON CONFLICT DO NOTHING;

  -- Muhammed Minshaj Hudawi Usthad — Nahv, Thajweed
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 1' AND u.name='Muhammed Minshaj Hudawi Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 1' AND u.name='Muhammed Minshaj Hudawi Usthad' AND s.name='Nahv' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 1' AND u.name='Muhammed Minshaj Hudawi Usthad' AND s.name='Thajweed' ON CONFLICT DO NOTHING;

  -- Noufal VM Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 1' AND u.name='Noufal VM Usthad' ON CONFLICT DO NOTHING;

  -- Sadiq Ali Usthad — Adab
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 1' AND u.name='Sadiq Ali Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 1' AND u.name='Sadiq Ali Usthad' AND s.name='Adab' ON CONFLICT DO NOTHING;

  -- Shameem Abdulla P S Usthad — Science, IT
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 1' AND u.name='Shameem Abdulla P S Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 1' AND u.name='Shameem Abdulla P S Usthad' AND s.name='Science' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 1' AND u.name='Shameem Abdulla P S Usthad' AND s.name='IT' ON CONFLICT DO NOTHING;

  -- Ashfaque Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 1' AND u.name='Ashfaque Usthad' ON CONFLICT DO NOTHING;

  -- Sajjad Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 1' AND u.name='Sajjad Usthad' ON CONFLICT DO NOTHING;

  -- ============================================================
  -- CLASS 2
  -- ============================================================
  -- Abdul Bari Hudawi Kari Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Abdul Bari Hudawi Kari Usthad' ON CONFLICT DO NOTHING;

  -- Abdul Samad Usthad — Social
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Abdul Samad Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 2' AND u.name='Abdul Samad Usthad' AND s.name='Social' ON CONFLICT DO NOTHING;

  -- Abdussamad PB Usthad — Fiqh, Hindi
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Abdussamad PB Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 2' AND u.name='Abdussamad PB Usthad' AND s.name='Fiqh' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 2' AND u.name='Abdussamad PB Usthad' AND s.name='Hindi' ON CONFLICT DO NOTHING;

  -- Ahmad Raees KA Usthad — English
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Ahmad Raees KA Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 2' AND u.name='Ahmad Raees KA Usthad' AND s.name='English' ON CONFLICT DO NOTHING;

  -- Ahmed BK Usthad — Hadeeth, Thajweed
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Ahmed BK Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 2' AND u.name='Ahmed BK Usthad' AND s.name='Hadeeth' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 2' AND u.name='Ahmed BK Usthad' AND s.name='Thajweed' ON CONFLICT DO NOTHING;

  -- Anwar Nuhmani Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Anwar Nuhmani Usthad' ON CONFLICT DO NOTHING;

  -- Ibrahim K M Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Ibrahim K M Usthad' ON CONFLICT DO NOTHING;

  -- Ibrahim Sadik Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Ibrahim Sadik Usthad' ON CONFLICT DO NOTHING;

  -- Lukuman Hakeem U S Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Lukuman Hakeem U S Usthad' ON CONFLICT DO NOTHING;

  -- Mohammad Naufal Usthad — Nahv
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Mohammad Naufal Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 2' AND u.name='Mohammad Naufal Usthad' AND s.name='Nahv' ON CONFLICT DO NOTHING;

  -- Mohammed Najeebullah A M Usthad — Science
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Mohammed Najeebullah A M Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 2' AND u.name='Mohammed Najeebullah A M Usthad' AND s.name='Science' ON CONFLICT DO NOTHING;

  -- Muhamed Anas P Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Muhamed Anas P Usthad' ON CONFLICT DO NOTHING;

  -- Muhammed CP Usthad — Swarf (Swadf)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Muhammed CP Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 2' AND u.name='Muhammed CP Usthad' AND s.name='Swadf' ON CONFLICT DO NOTHING;

  -- Muhammed Hudawi Vengad Usthad — Malayalam
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Muhammed Hudawi Vengad Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 2' AND u.name='Muhammed Hudawi Vengad Usthad' AND s.name='Malayalam' ON CONFLICT DO NOTHING;

  -- Muhammed Ishaq Usthad — Thareeq
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Muhammed Ishaq Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 2' AND u.name='Muhammed Ishaq Usthad' AND s.name='Thareeq' ON CONFLICT DO NOTHING;

  -- Muhammed Minshaj Hudawi Usthad — Aqeeda
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Muhammed Minshaj Hudawi Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 2' AND u.name='Muhammed Minshaj Hudawi Usthad' AND s.name='Aqeeda' ON CONFLICT DO NOTHING;

  -- Noufal VM Usthad — Urdu
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Noufal VM Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 2' AND u.name='Noufal VM Usthad' AND s.name='Urdu' ON CONFLICT DO NOTHING;

  -- Sadiq Ali Usthad — T&C
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Sadiq Ali Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 2' AND u.name='Sadiq Ali Usthad' AND s.name='T&C' ON CONFLICT DO NOTHING;

  -- Shameem Abdulla P S Usthad — Adab, IT
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Shameem Abdulla P S Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 2' AND u.name='Shameem Abdulla P S Usthad' AND s.name='Adab' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 2' AND u.name='Shameem Abdulla P S Usthad' AND s.name='IT' ON CONFLICT DO NOTHING;

  -- Ashfaque Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Ashfaque Usthad' ON CONFLICT DO NOTHING;

  -- Sajjad Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Sajjad Usthad' ON CONFLICT DO NOTHING;

  -- Shamseer Usthad — Maths
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 2' AND u.name='Shamseer Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 2' AND u.name='Shamseer Usthad' AND s.name='Maths' ON CONFLICT DO NOTHING;

  -- ============================================================
  -- CLASS 3
  -- ============================================================
  -- Abdul Bari Hudawi Kari Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Abdul Bari Hudawi Kari Usthad' ON CONFLICT DO NOTHING;

  -- Abdul Samad Usthad — Malayalam
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Abdul Samad Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 3' AND u.name='Abdul Samad Usthad' AND s.name='Malayalam' ON CONFLICT DO NOTHING;

  -- Abdussamad PB Usthad — Thareeq, Hindi
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Abdussamad PB Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 3' AND u.name='Abdussamad PB Usthad' AND s.name='Thareeq' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 3' AND u.name='Abdussamad PB Usthad' AND s.name='Hindi' ON CONFLICT DO NOTHING;

  -- Ahmad Raees KA Usthad — English
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Ahmad Raees KA Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 3' AND u.name='Ahmad Raees KA Usthad' AND s.name='English' ON CONFLICT DO NOTHING;

  -- Ahmed BK Usthad — Nahv, Tajveed
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Ahmed BK Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 3' AND u.name='Ahmed BK Usthad' AND s.name='Nahv' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 3' AND u.name='Ahmed BK Usthad' AND s.name='Tajveed' ON CONFLICT DO NOTHING;

  -- Anwar Nuhmani Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Anwar Nuhmani Usthad' ON CONFLICT DO NOTHING;

  -- Ibrahim K M Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Ibrahim K M Usthad' ON CONFLICT DO NOTHING;

  -- Ibrahim Sadik Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Ibrahim Sadik Usthad' ON CONFLICT DO NOTHING;

  -- Lukuman Hakeem U S Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Lukuman Hakeem U S Usthad' ON CONFLICT DO NOTHING;

  -- Mohammad Naufal Usthad — Hadeeth
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Mohammad Naufal Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 3' AND u.name='Mohammad Naufal Usthad' AND s.name='Hadeeth' ON CONFLICT DO NOTHING;

  -- Mohammed Najeebullah A M Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Mohammed Najeebullah A M Usthad' ON CONFLICT DO NOTHING;

  -- Muhamed Anas P Usthad — Swarf (Swadf)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Muhamed Anas P Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 3' AND u.name='Muhamed Anas P Usthad' AND s.name='Swadf' ON CONFLICT DO NOTHING;

  -- Muhammed CP Usthad — T&C
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Muhammed CP Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 3' AND u.name='Muhammed CP Usthad' AND s.name='T&C' ON CONFLICT DO NOTHING;

  -- Muhammed Hudawi Vengad Usthad — Fiqh
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Muhammed Hudawi Vengad Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 3' AND u.name='Muhammed Hudawi Vengad Usthad' AND s.name='Fiqh' ON CONFLICT DO NOTHING;

  -- Muhammed Ishaq Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Muhammed Ishaq Usthad' ON CONFLICT DO NOTHING;

  -- Muhammed Minshaj Hudawi Usthad — Adab
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Muhammed Minshaj Hudawi Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 3' AND u.name='Muhammed Minshaj Hudawi Usthad' AND s.name='Adab' ON CONFLICT DO NOTHING;

  -- Noufal VM Usthad — Urdu
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Noufal VM Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 3' AND u.name='Noufal VM Usthad' AND s.name='Urdu' ON CONFLICT DO NOTHING;

  -- Sadiq Ali Usthad — Thasawuf
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Sadiq Ali Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 3' AND u.name='Sadiq Ali Usthad' AND s.name='Thasawuf' ON CONFLICT DO NOTHING;

  -- Shameem Abdulla P S Usthad — IT, Social
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Shameem Abdulla P S Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 3' AND u.name='Shameem Abdulla P S Usthad' AND s.name='IT' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 3' AND u.name='Shameem Abdulla P S Usthad' AND s.name='Social' ON CONFLICT DO NOTHING;

  -- Ashfaque Usthad — Maths, Science
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Ashfaque Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 3' AND u.name='Ashfaque Usthad' AND s.name='Maths' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 3' AND u.name='Ashfaque Usthad' AND s.name='Science' ON CONFLICT DO NOTHING;

  -- Sajjad Usthad — Maths, Science
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 3' AND u.name='Sajjad Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 3' AND u.name='Sajjad Usthad' AND s.name='Maths' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 3' AND u.name='Sajjad Usthad' AND s.name='Science' ON CONFLICT DO NOTHING;

  -- ============================================================
  -- CLASS 4
  -- ============================================================
  -- Abdul Bari Hudawi Kari Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Abdul Bari Hudawi Kari Usthad' ON CONFLICT DO NOTHING;

  -- Abdul Samad Usthad — Malayalam, Thasawuf
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Abdul Samad Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 4' AND u.name='Abdul Samad Usthad' AND s.name='Malayalam' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 4' AND u.name='Abdul Samad Usthad' AND s.name='Thasawuf' ON CONFLICT DO NOTHING;

  -- Abdussamad PB Usthad — Hindi
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Abdussamad PB Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 4' AND u.name='Abdussamad PB Usthad' AND s.name='Hindi' ON CONFLICT DO NOTHING;

  -- Ahmad Raees KA Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Ahmad Raees KA Usthad' ON CONFLICT DO NOTHING;

  -- Ahmed BK Usthad — Adab
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Ahmed BK Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 4' AND u.name='Ahmed BK Usthad' AND s.name='Adab' ON CONFLICT DO NOTHING;

  -- Anwar Nuhmani Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Anwar Nuhmani Usthad' ON CONFLICT DO NOTHING;

  -- Ibrahim K Usthad (no subject) — note: Class 4 uses "Ibrahim K Usthad" not "Ibrahim K M Usthad"
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Ibrahim K Usthad' ON CONFLICT DO NOTHING;

  -- Ibrahim Sadik Usthad — Fiqh
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Ibrahim Sadik Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 4' AND u.name='Ibrahim Sadik Usthad' AND s.name='Fiqh' ON CONFLICT DO NOTHING;

  -- Lukuman Hakeem U S Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Lukuman Hakeem U S Usthad' ON CONFLICT DO NOTHING;

  -- Mohammad Naufal Usthad — English
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Mohammad Naufal Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 4' AND u.name='Mohammad Naufal Usthad' AND s.name='English' ON CONFLICT DO NOTHING;

  -- Mohammed Najeebullah A M Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Mohammed Najeebullah A M Usthad' ON CONFLICT DO NOTHING;

  -- Muhamed Anas P Usthad — Social Science
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Muhamed Anas P Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 4' AND u.name='Muhamed Anas P Usthad' AND s.name='Social Science' ON CONFLICT DO NOTHING;

  -- Muhammed CP Usthad — T&C, Thajweed
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Muhammed CP Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 4' AND u.name='Muhammed CP Usthad' AND s.name='T&C' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 4' AND u.name='Muhammed CP Usthad' AND s.name='Thajweed' ON CONFLICT DO NOTHING;

  -- Muhammed Hudawi Vengad Usthad — Aqeeda
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Muhammed Hudawi Vengad Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 4' AND u.name='Muhammed Hudawi Vengad Usthad' AND s.name='Aqeeda' ON CONFLICT DO NOTHING;

  -- Muhammed Ishaq Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Muhammed Ishaq Usthad' ON CONFLICT DO NOTHING;

  -- Muhammed Minshaj Hudawi Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Muhammed Minshaj Hudawi Usthad' ON CONFLICT DO NOTHING;

  -- Noufal VM Usthad — Urdu, Thareeq
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Noufal VM Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 4' AND u.name='Noufal VM Usthad' AND s.name='Urdu' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 4' AND u.name='Noufal VM Usthad' AND s.name='Thareeq' ON CONFLICT DO NOTHING;

  -- Sadiq Ali Usthad — Hadeeth
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Sadiq Ali Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 4' AND u.name='Sadiq Ali Usthad' AND s.name='Hadeeth' ON CONFLICT DO NOTHING;

  -- Shameem Abdulla P S Usthad — Nahv, IT
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Shameem Abdulla P S Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 4' AND u.name='Shameem Abdulla P S Usthad' AND s.name='Nahv' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 4' AND u.name='Shameem Abdulla P S Usthad' AND s.name='IT' ON CONFLICT DO NOTHING;

  -- Ashfaque Usthad — Science, Maths
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Ashfaque Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 4' AND u.name='Ashfaque Usthad' AND s.name='Science' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 4' AND u.name='Ashfaque Usthad' AND s.name='Maths' ON CONFLICT DO NOTHING;

  -- Sajjad Usthad — Science, Maths
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 4' AND u.name='Sajjad Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 4' AND u.name='Sajjad Usthad' AND s.name='Science' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 4' AND u.name='Sajjad Usthad' AND s.name='Maths' ON CONFLICT DO NOTHING;

  -- ============================================================
  -- CLASS 5
  -- ============================================================
  -- Abdul Bari Hudawi Kari Usthad — Thasawuf
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Abdul Bari Hudawi Kari Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Abdul Bari Hudawi Kari Usthad' AND s.name='Thasawuf' ON CONFLICT DO NOTHING;

  -- Abdul Samad Usthad — Social
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Abdul Samad Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Abdul Samad Usthad' AND s.name='Social' ON CONFLICT DO NOTHING;

  -- Abdussamad PB Usthad — Hindi
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Abdussamad PB Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Abdussamad PB Usthad' AND s.name='Hindi' ON CONFLICT DO NOTHING;

  -- Ahmad Raees KA Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Ahmad Raees KA Usthad' ON CONFLICT DO NOTHING;

  -- Ahmed BK Usthad — Alfiyya
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Ahmed BK Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Ahmed BK Usthad' AND s.name='Alfiyya' ON CONFLICT DO NOTHING;

  -- Anwar Nuhmani Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Anwar Nuhmani Usthad' ON CONFLICT DO NOTHING;

  -- Ibrahim K M Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Ibrahim K M Usthad' ON CONFLICT DO NOTHING;

  -- Ibrahim Sadik Usthad — Nahv
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Ibrahim Sadik Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Ibrahim Sadik Usthad' AND s.name='Nahv' ON CONFLICT DO NOTHING;

  -- Lukuman Hakeem U S Usthad — Fiqh
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Lukuman Hakeem U S Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Lukuman Hakeem U S Usthad' AND s.name='Fiqh' ON CONFLICT DO NOTHING;

  -- Mohammad Naufal Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Mohammad Naufal Usthad' ON CONFLICT DO NOTHING;

  -- Mohammed Najeebullah A M Usthad — English
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Mohammed Najeebullah A M Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Mohammed Najeebullah A M Usthad' AND s.name='English' ON CONFLICT DO NOTHING;

  -- Muhamed Anas P Usthad — T&C
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Muhamed Anas P Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Muhamed Anas P Usthad' AND s.name='T&C' ON CONFLICT DO NOTHING;

  -- Muhammed CP Usthad — Thareeq, Thafseer
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Muhammed CP Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Muhammed CP Usthad' AND s.name='Thareeq' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Muhammed CP Usthad' AND s.name='Thafseer' ON CONFLICT DO NOTHING;

  -- Muhammed Hudawi Vengad Usthad — Malayalam
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Muhammed Hudawi Vengad Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Muhammed Hudawi Vengad Usthad' AND s.name='Malayalam' ON CONFLICT DO NOTHING;

  -- Muhammed Ishaq Usthad — Hadeeth
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Muhammed Ishaq Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Muhammed Ishaq Usthad' AND s.name='Hadeeth' ON CONFLICT DO NOTHING;

  -- Muhammed Minshaj Hudawi Usthad — Adab
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Muhammed Minshaj Hudawi Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Muhammed Minshaj Hudawi Usthad' AND s.name='Adab' ON CONFLICT DO NOTHING;

  -- Noufal VM Usthad — Urdu
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Noufal VM Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Noufal VM Usthad' AND s.name='Urdu' ON CONFLICT DO NOTHING;

  -- Sadiq Ali Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Sadiq Ali Usthad' ON CONFLICT DO NOTHING;

  -- Shameem Abdulla P S Usthad — IT
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Shameem Abdulla P S Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Shameem Abdulla P S Usthad' AND s.name='IT' ON CONFLICT DO NOTHING;

  -- Ashfaque Usthad — Maths, Biology
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Ashfaque Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Ashfaque Usthad' AND s.name='Maths' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Ashfaque Usthad' AND s.name='Biology' ON CONFLICT DO NOTHING;

  -- Sajjad Usthad — Maths, Biology, Physics, Chemistry
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 5' AND u.name='Sajjad Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Sajjad Usthad' AND s.name='Maths' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Sajjad Usthad' AND s.name='Biology' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Sajjad Usthad' AND s.name='Physics' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 5' AND u.name='Sajjad Usthad' AND s.name='Chemistry' ON CONFLICT DO NOTHING;

  -- ============================================================
  -- CLASS 6
  -- ============================================================
  -- Abdul Bari Hudawi Kari Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Abdul Bari Hudawi Kari Usthad' ON CONFLICT DO NOTHING;

  -- Abdul Samad Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Abdul Samad Usthad' ON CONFLICT DO NOTHING;

  -- Abdussamad PB Usthad — Balaga
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Abdussamad PB Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 6' AND u.name='Abdussamad PB Usthad' AND s.name='Balaga' ON CONFLICT DO NOTHING;

  -- Ahmad Raees KA Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Ahmad Raees KA Usthad' ON CONFLICT DO NOTHING;

  -- Ahmed BK Usthad — Economics, Politics, Business Studies
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Ahmed BK Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 6' AND u.name='Ahmed BK Usthad' AND s.name='Economics' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 6' AND u.name='Ahmed BK Usthad' AND s.name='Politics' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 6' AND u.name='Ahmed BK Usthad' AND s.name='Business Studies' ON CONFLICT DO NOTHING;

  -- Anwar Nuhmani Usthad — Urdu
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Anwar Nuhmani Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 6' AND u.name='Anwar Nuhmani Usthad' AND s.name='Urdu' ON CONFLICT DO NOTHING;

  -- Ibrahim K M Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Ibrahim K M Usthad' ON CONFLICT DO NOTHING;

  -- Ibrahim Sadik Usthad — Alfiyya
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Ibrahim Sadik Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 6' AND u.name='Ibrahim Sadik Usthad' AND s.name='Alfiyya' ON CONFLICT DO NOTHING;

  -- Lukuman Hakeem U S Usthad — Thamaddun
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Lukuman Hakeem U S Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 6' AND u.name='Lukuman Hakeem U S Usthad' AND s.name='Thamaddun' ON CONFLICT DO NOTHING;

  -- Mohammad Naufal Usthad — English
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Mohammad Naufal Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 6' AND u.name='Mohammad Naufal Usthad' AND s.name='English' ON CONFLICT DO NOTHING;

  -- Mohammed Najeebullah A M Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Mohammed Najeebullah A M Usthad' ON CONFLICT DO NOTHING;

  -- Muhamed Anas P Usthad — Fiqh
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Muhamed Anas P Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 6' AND u.name='Muhamed Anas P Usthad' AND s.name='Fiqh' ON CONFLICT DO NOTHING;

  -- Muhammed CP Usthad — T&C
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Muhammed CP Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 6' AND u.name='Muhammed CP Usthad' AND s.name='T&C' ON CONFLICT DO NOTHING;

  -- Muhammed Hudawi Vengad Usthad — Hadeeth
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Muhammed Hudawi Vengad Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 6' AND u.name='Muhammed Hudawi Vengad Usthad' AND s.name='Hadeeth' ON CONFLICT DO NOTHING;

  -- Muhammed Ishaq Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Muhammed Ishaq Usthad' ON CONFLICT DO NOTHING;

  -- Muhammed Minshaj Hudawi Usthad — History
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Muhammed Minshaj Hudawi Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 6' AND u.name='Muhammed Minshaj Hudawi Usthad' AND s.name='History' ON CONFLICT DO NOTHING;

  -- Noufal VM Usthad — Thafseer
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Noufal VM Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 6' AND u.name='Noufal VM Usthad' AND s.name='Thafseer' ON CONFLICT DO NOTHING;

  -- Sadiq Ali Usthad — Adab, Sociology
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Sadiq Ali Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 6' AND u.name='Sadiq Ali Usthad' AND s.name='Adab' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 6' AND u.name='Sadiq Ali Usthad' AND s.name='Sociology' ON CONFLICT DO NOTHING;

  -- Shameem Abdulla P S Usthad — IT, Computer Application
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Shameem Abdulla P S Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 6' AND u.name='Shameem Abdulla P S Usthad' AND s.name='IT' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 6' AND u.name='Shameem Abdulla P S Usthad' AND s.name='Computer Application' ON CONFLICT DO NOTHING;

  -- Ashfaque Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Ashfaque Usthad' ON CONFLICT DO NOTHING;

  -- Sajjad Usthad — Accountancy
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 6' AND u.name='Sajjad Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 6' AND u.name='Sajjad Usthad' AND s.name='Accountancy' ON CONFLICT DO NOTHING;

  -- ============================================================
  -- CLASS 7
  -- ============================================================
  -- Abdul Bari Hudawi Kari Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Abdul Bari Hudawi Kari Usthad' ON CONFLICT DO NOTHING;

  -- Abdul Samad Usthad — Sociology
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Abdul Samad Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 7' AND u.name='Abdul Samad Usthad' AND s.name='Sociology' ON CONFLICT DO NOTHING;

  -- Abdussamad PB Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Abdussamad PB Usthad' ON CONFLICT DO NOTHING;

  -- Ahmad Raees KA Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Ahmad Raees KA Usthad' ON CONFLICT DO NOTHING;

  -- Ahmed BK Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Ahmed BK Usthad' ON CONFLICT DO NOTHING;

  -- Anwar Nuhmani Usthad — Urdu, Hadeeth
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Anwar Nuhmani Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 7' AND u.name='Anwar Nuhmani Usthad' AND s.name='Urdu' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 7' AND u.name='Anwar Nuhmani Usthad' AND s.name='Hadeeth' ON CONFLICT DO NOTHING;

  -- Ibrahim K M Usthad — Usul al Fiqh
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Ibrahim K M Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 7' AND u.name='Ibrahim K M Usthad' AND s.name='Usul al Fiqh' ON CONFLICT DO NOTHING;

  -- Ibrahim Sadik Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Ibrahim Sadik Usthad' ON CONFLICT DO NOTHING;

  -- Lukuman Hakeem U S Usthad — Fiqh
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Lukuman Hakeem U S Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 7' AND u.name='Lukuman Hakeem U S Usthad' AND s.name='Fiqh' ON CONFLICT DO NOTHING;

  -- Mohammad Naufal Usthad — Alfiyya
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Mohammad Naufal Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 7' AND u.name='Mohammad Naufal Usthad' AND s.name='Alfiyya' ON CONFLICT DO NOTHING;

  -- Mohammed Najeebullah A M Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Mohammed Najeebullah A M Usthad' ON CONFLICT DO NOTHING;

  -- Muhamed Anas P Usthad — English
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Muhamed Anas P Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 7' AND u.name='Muhamed Anas P Usthad' AND s.name='English' ON CONFLICT DO NOTHING;

  -- Muhammed CP Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Muhammed CP Usthad' ON CONFLICT DO NOTHING;

  -- Muhammed Hudawi Vengad Usthad — Thasawuf, Balaga
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Muhammed Hudawi Vengad Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 7' AND u.name='Muhammed Hudawi Vengad Usthad' AND s.name='Thasawuf' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 7' AND u.name='Muhammed Hudawi Vengad Usthad' AND s.name='Balaga' ON CONFLICT DO NOTHING;

  -- Muhammed Ishaq Usthad — Economics, Political Science
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Muhammed Ishaq Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 7' AND u.name='Muhammed Ishaq Usthad' AND s.name='Economics' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 7' AND u.name='Muhammed Ishaq Usthad' AND s.name='Political Science' ON CONFLICT DO NOTHING;

  -- Muhammed Minshaj Hudawi Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Muhammed Minshaj Hudawi Usthad' ON CONFLICT DO NOTHING;

  -- Noufal VM Usthad — Thafseer
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Noufal VM Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 7' AND u.name='Noufal VM Usthad' AND s.name='Thafseer' ON CONFLICT DO NOTHING;

  -- Sadiq Ali Usthad — Adab, T&C
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Sadiq Ali Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 7' AND u.name='Sadiq Ali Usthad' AND s.name='Adab' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 7' AND u.name='Sadiq Ali Usthad' AND s.name='T&C' ON CONFLICT DO NOTHING;

  -- Shameem Abdulla P S Usthad — IT
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Shameem Abdulla P S Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 7' AND u.name='Shameem Abdulla P S Usthad' AND s.name='IT' ON CONFLICT DO NOTHING;

  -- Ashfaque Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Ashfaque Usthad' ON CONFLICT DO NOTHING;

  -- Sajjad Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Sajjad Usthad' ON CONFLICT DO NOTHING;

  -- Shamseer Usthad — Thamaddun
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 7' AND u.name='Shamseer Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 7' AND u.name='Shamseer Usthad' AND s.name='Thamaddun' ON CONFLICT DO NOTHING;

  -- ============================================================
  -- CLASS 8
  -- ============================================================
  -- Abdul Bari Hudawi Kari Usthad — Thasawuf and Aqeeda (ONE subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Abdul Bari Hudawi Kari Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 8' AND u.name='Abdul Bari Hudawi Kari Usthad' AND s.name='Thasawuf and Aqeeda' ON CONFLICT DO NOTHING;

  -- Abdul Samad Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Abdul Samad Usthad' ON CONFLICT DO NOTHING;

  -- Abdussamad PB Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Abdussamad PB Usthad' ON CONFLICT DO NOTHING;

  -- Ahmad Raees KA Usthad — Thahqeeq, Fatwa
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Ahmad Raees KA Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 8' AND u.name='Ahmad Raees KA Usthad' AND s.name='Thahqeeq' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 8' AND u.name='Ahmad Raees KA Usthad' AND s.name='Fatwa' ON CONFLICT DO NOTHING;

  -- Ahmed BK Usthad — Adab
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Ahmed BK Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 8' AND u.name='Ahmed BK Usthad' AND s.name='Adab' ON CONFLICT DO NOTHING;

  -- Anwar Nuhmani Usthad — Urdu, Hadeeth
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Anwar Nuhmani Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 8' AND u.name='Anwar Nuhmani Usthad' AND s.name='Urdu' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 8' AND u.name='Anwar Nuhmani Usthad' AND s.name='Hadeeth' ON CONFLICT DO NOTHING;

  -- Ibrahim K M Usthad — U Fiqh
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Ibrahim K M Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 8' AND u.name='Ibrahim K M Usthad' AND s.name='U Fiqh' ON CONFLICT DO NOTHING;

  -- Ibrahim Sadik Usthad — Thamaddun
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Ibrahim Sadik Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 8' AND u.name='Ibrahim Sadik Usthad' AND s.name='Thamaddun' ON CONFLICT DO NOTHING;

  -- Lukuman Hakeem U S Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Lukuman Hakeem U S Usthad' ON CONFLICT DO NOTHING;

  -- Mohammad Naufal Usthad — Balaga
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Mohammad Naufal Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 8' AND u.name='Mohammad Naufal Usthad' AND s.name='Balaga' ON CONFLICT DO NOTHING;

  -- Mohammed Najeebullah A M Usthad — Thakassus
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Mohammed Najeebullah A M Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 8' AND u.name='Mohammed Najeebullah A M Usthad' AND s.name='Thakassus' ON CONFLICT DO NOTHING;

  -- Muhamed Anas P Usthad — Fiqh
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Muhamed Anas P Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 8' AND u.name='Muhamed Anas P Usthad' AND s.name='Fiqh' ON CONFLICT DO NOTHING;

  -- Muhammed CP Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Muhammed CP Usthad' ON CONFLICT DO NOTHING;

  -- Muhammed Hudawi Vengad Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Muhammed Hudawi Vengad Usthad' ON CONFLICT DO NOTHING;

  -- Muhammed Ishaq Usthad — Mantiq and Philosophy (ONE subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Muhammed Ishaq Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 8' AND u.name='Muhammed Ishaq Usthad' AND s.name='Mantiq and Philosophy' ON CONFLICT DO NOTHING;

  -- Muhammed Minshaj Hudawi Usthad — Social
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Muhammed Minshaj Hudawi Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 8' AND u.name='Muhammed Minshaj Hudawi Usthad' AND s.name='Social' ON CONFLICT DO NOTHING;

  -- Noufal VM Usthad — Thafseer
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Noufal VM Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 8' AND u.name='Noufal VM Usthad' AND s.name='Thafseer' ON CONFLICT DO NOTHING;

  -- Sadiq Ali Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Sadiq Ali Usthad' ON CONFLICT DO NOTHING;

  -- Shameem Abdulla P S Usthad — English
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Shameem Abdulla P S Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 8' AND u.name='Shameem Abdulla P S Usthad' AND s.name='English' ON CONFLICT DO NOTHING;

  -- Ashfaque Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Ashfaque Usthad' ON CONFLICT DO NOTHING;

  -- Sajjad Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 8' AND u.name='Sajjad Usthad' ON CONFLICT DO NOTHING;

  -- ============================================================
  -- CLASS 9
  -- ============================================================
  -- Abdul Bari Hudawi Kari Usthad — Balaga
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Abdul Bari Hudawi Kari Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 9' AND u.name='Abdul Bari Hudawi Kari Usthad' AND s.name='Balaga' ON CONFLICT DO NOTHING;

  -- Abdul Samad Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Abdul Samad Usthad' ON CONFLICT DO NOTHING;

  -- Abdussamad PB Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Abdussamad PB Usthad' ON CONFLICT DO NOTHING;

  -- Ahmad Raees KA Usthad — Thakassus
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Ahmad Raees KA Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 9' AND u.name='Ahmad Raees KA Usthad' AND s.name='Thakassus' ON CONFLICT DO NOTHING;

  -- Ahmed BK Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Ahmed BK Usthad' ON CONFLICT DO NOTHING;

  -- Anwar Nuhmani Usthad — Urdu, Hadeeth
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Anwar Nuhmani Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 9' AND u.name='Anwar Nuhmani Usthad' AND s.name='Urdu' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 9' AND u.name='Anwar Nuhmani Usthad' AND s.name='Hadeeth' ON CONFLICT DO NOTHING;

  -- Ibrahim K M Usthad — UFiqh, Mantiq
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Ibrahim K M Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 9' AND u.name='Ibrahim K M Usthad' AND s.name='UFiqh' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 9' AND u.name='Ibrahim K M Usthad' AND s.name='Mantiq' ON CONFLICT DO NOTHING;

  -- Ibrahim Sadik Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Ibrahim Sadik Usthad' ON CONFLICT DO NOTHING;

  -- Lukuman Hakeem U S Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Lukuman Hakeem U S Usthad' ON CONFLICT DO NOTHING;

  -- Mohammad Naufal Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Mohammad Naufal Usthad' ON CONFLICT DO NOTHING;

  -- Mohammed Najeebullah A M Usthad — English
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Mohammed Najeebullah A M Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 9' AND u.name='Mohammed Najeebullah A M Usthad' AND s.name='English' ON CONFLICT DO NOTHING;

  -- Muhamed Anas P Usthad — Thamaddun
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Muhamed Anas P Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 9' AND u.name='Muhamed Anas P Usthad' AND s.name='Thamaddun' ON CONFLICT DO NOTHING;

  -- Muhammed CP Usthad — Fiqh, Tahqeeq, Fatwa
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Muhammed CP Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 9' AND u.name='Muhammed CP Usthad' AND s.name='Fiqh' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 9' AND u.name='Muhammed CP Usthad' AND s.name='Tahqeeq' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 9' AND u.name='Muhammed CP Usthad' AND s.name='Fatwa' ON CONFLICT DO NOTHING;

  -- Muhammed Hudawi Vengad Usthad — Thafseer
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Muhammed Hudawi Vengad Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 9' AND u.name='Muhammed Hudawi Vengad Usthad' AND s.name='Thafseer' ON CONFLICT DO NOTHING;

  -- Muhammed Ishaq Usthad — Thasawuf and Aqeeda (ONE subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Muhammed Ishaq Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 9' AND u.name='Muhammed Ishaq Usthad' AND s.name='Thasawuf and Aqeeda' ON CONFLICT DO NOTHING;

  -- Muhammed Minshaj Hudawi Usthad — Social
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Muhammed Minshaj Hudawi Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 9' AND u.name='Muhammed Minshaj Hudawi Usthad' AND s.name='Social' ON CONFLICT DO NOTHING;

  -- Noufal VM Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Noufal VM Usthad' ON CONFLICT DO NOTHING;

  -- Sadiq Ali Usthad — Adab
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Sadiq Ali Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 9' AND u.name='Sadiq Ali Usthad' AND s.name='Adab' ON CONFLICT DO NOTHING;

  -- Shameem Abdulla P S Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Shameem Abdulla P S Usthad' ON CONFLICT DO NOTHING;

  -- Ashfaque Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Ashfaque Usthad' ON CONFLICT DO NOTHING;

  -- Sajjad Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 9' AND u.name='Sajjad Usthad' ON CONFLICT DO NOTHING;

  -- ============================================================
  -- CLASS 10
  -- ============================================================
  -- Abdul Bari Hudawi Kari Usthad — Thasawuf and Aqeeda (ONE subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Abdul Bari Hudawi Kari Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 10' AND u.name='Abdul Bari Hudawi Kari Usthad' AND s.name='Thasawuf and Aqeeda' ON CONFLICT DO NOTHING;

  -- Abdul Samad Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Abdul Samad Usthad' ON CONFLICT DO NOTHING;

  -- Abdussamad PB Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Abdussamad PB Usthad' ON CONFLICT DO NOTHING;

  -- Ahmad Raees KA Usthad — Fiqh
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Ahmad Raees KA Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 10' AND u.name='Ahmad Raees KA Usthad' AND s.name='Fiqh' ON CONFLICT DO NOTHING;

  -- Ahmed BK Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Ahmed BK Usthad' ON CONFLICT DO NOTHING;

  -- Anwar Nuhmani Usthad — Hadeeth, Urdu
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Anwar Nuhmani Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 10' AND u.name='Anwar Nuhmani Usthad' AND s.name='Hadeeth' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 10' AND u.name='Anwar Nuhmani Usthad' AND s.name='Urdu' ON CONFLICT DO NOTHING;

  -- Ibrahim K M Usthad — Usul al Fiqh
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Ibrahim K M Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 10' AND u.name='Ibrahim K M Usthad' AND s.name='Usul al Fiqh' ON CONFLICT DO NOTHING;

  -- Ibrahim Sadik Usthad — Adab
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Ibrahim Sadik Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 10' AND u.name='Ibrahim Sadik Usthad' AND s.name='Adab' ON CONFLICT DO NOTHING;

  -- Lukuman Hakeem U S Usthad — Balaga
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Lukuman Hakeem U S Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 10' AND u.name='Lukuman Hakeem U S Usthad' AND s.name='Balaga' ON CONFLICT DO NOTHING;

  -- Mohammad Naufal Usthad — English
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Mohammad Naufal Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 10' AND u.name='Mohammad Naufal Usthad' AND s.name='English' ON CONFLICT DO NOTHING;

  -- Mohammed Najeebullah A M Usthad — Mantiq and Philosophy (ONE subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Mohammed Najeebullah A M Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 10' AND u.name='Mohammed Najeebullah A M Usthad' AND s.name='Mantiq and Philosophy' ON CONFLICT DO NOTHING;

  -- Muhamed Anas P Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Muhamed Anas P Usthad' ON CONFLICT DO NOTHING;

  -- Muhammed CP Usthad — Thakassus
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Muhammed CP Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 10' AND u.name='Muhammed CP Usthad' AND s.name='Thakassus' ON CONFLICT DO NOTHING;

  -- Muhammed Hudawi Vengad Usthad — Thahqeeq, GK
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Muhammed Hudawi Vengad Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 10' AND u.name='Muhammed Hudawi Vengad Usthad' AND s.name='Thahqeeq' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 10' AND u.name='Muhammed Hudawi Vengad Usthad' AND s.name='GK' ON CONFLICT DO NOTHING;

  -- Muhammed Ishaq Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Muhammed Ishaq Usthad' ON CONFLICT DO NOTHING;

  -- Muhammed Minshaj Hudawi Usthad — Social
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Muhammed Minshaj Hudawi Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 10' AND u.name='Muhammed Minshaj Hudawi Usthad' AND s.name='Social' ON CONFLICT DO NOTHING;

  -- Noufal VM Usthad — Thafseer
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Noufal VM Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 10' AND u.name='Noufal VM Usthad' AND s.name='Thafseer' ON CONFLICT DO NOTHING;

  -- Sadiq Ali Usthad — TMDN
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Sadiq Ali Usthad' ON CONFLICT DO NOTHING;
  INSERT INTO class_usthad_subjects (class_usthad_id, subject_id) SELECT cu.id, s.id FROM class_usthads cu, subjects s, classes c, usthads u WHERE cu.class_id=c.id AND cu.usthad_id=u.id AND c.name='Class 10' AND u.name='Sadiq Ali Usthad' AND s.name='TMDN' ON CONFLICT DO NOTHING;

  -- Shameem Abdulla P S Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Shameem Abdulla P S Usthad' ON CONFLICT DO NOTHING;

  -- Ashfaque Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Ashfaque Usthad' ON CONFLICT DO NOTHING;

  -- Sajjad Usthad (no subject)
  INSERT INTO class_usthads (class_id, usthad_id) SELECT c.id, u.id FROM classes c, usthads u WHERE c.name='Class 10' AND u.name='Sajjad Usthad' ON CONFLICT DO NOTHING;

END $$;